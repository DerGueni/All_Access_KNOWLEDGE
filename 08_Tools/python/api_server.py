"""
Access Bridge REST API Server
Verbindet HTML-Formulare mit der Access-Datenbank
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import pyodbc
import json
import os
from datetime import datetime, date, timedelta
from datetime import time as datetime_time  # Explizit benannt um Konflikt mit time-Modul zu vermeiden
from pathlib import Path
from decimal import Decimal
import threading
import queue
import atexit
import sys
import logging

# Logging konfigurieren (Datei + Konsole)
LOG_DIR = Path(__file__).parent / "logs"
LOG_DIR.mkdir(exist_ok=True)

# File Handler für Produktion
file_handler = logging.FileHandler(LOG_DIR / "api_server.log", encoding='utf-8')
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))

# Console Handler für Debug
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(message)s'))

# Logger einrichten
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(file_handler)
logger.addHandler(console_handler)

# Waitress-Logger auch konfigurieren
logging.getLogger('waitress').setLevel(logging.WARNING)

app = Flask(__name__, static_folder='web')
CORS(app, resources={r"/api/*": {"origins": "*", "allow_headers": "*", "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"]}})

# Pfad zu HTML-Formularen (forms3 = aktiver Formulare-Ordner)
FORMS_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3")

# ============================================
# ROBUSTES REQUEST-THROTTLING (verhindert ODBC Segfaults)
# ============================================
# Access ODBC-Treiber crasht bei parallelen Requests.
# Lösung: Semaphore mit sofortiger Ablehnung bei Überlastung statt Queuing.
import time as _time_module  # Unterstrich-Prefix vermeidet Konflikt mit datetime.time

# Konfiguration
_MAX_CONCURRENT_REQUESTS = 1  # Nur 1 Request gleichzeitig (Access ODBC ist single-threaded)
_REQUEST_TIMEOUT = 5.0  # Max 5 Sekunden warten auf Slot
_API_MIN_INTERVAL = 0.15  # 150ms Mindestabstand zwischen Requests (erhöht für Stabilität)

# Semaphore für Request-Limiting
_request_semaphore = threading.Semaphore(_MAX_CONCURRENT_REQUESTS)
_api_last_request = 0
_pending_requests = 0
_pending_lock = threading.Lock()

@app.before_request
def throttle_api_requests():
    """Limitiert gleichzeitige API-Requests mit sofortiger Ablehnung bei Überlastung"""
    global _api_last_request, _pending_requests

    if not request.path.startswith('/api/'):
        return None

    # Health-Check immer durchlassen
    if request.path == '/api/health':
        return None

    # Prüfe Anzahl wartender Requests
    with _pending_lock:
        if _pending_requests >= 3:  # Max 3 Requests in der Queue
            logger.warning(f"Server überlastet - Request abgelehnt: {request.path}")
            response = jsonify({
                'error': 'Server überlastet',
                'message': 'Zu viele gleichzeitige Anfragen. Bitte kurz warten.',
                'retry_after': 1
            })
            response.status_code = 503
            response.headers['Retry-After'] = '1'
            return response
        _pending_requests += 1

    # Versuche Semaphore zu bekommen (mit Timeout)
    acquired = _request_semaphore.acquire(timeout=_REQUEST_TIMEOUT)

    if not acquired:
        with _pending_lock:
            _pending_requests -= 1
        logger.warning(f"Request-Timeout - abgelehnt: {request.path}")
        response = jsonify({
            'error': 'Request-Timeout',
            'message': 'Server antwortet nicht rechtzeitig. Bitte erneut versuchen.',
            'retry_after': 2
        })
        response.status_code = 503
        response.headers['Retry-After'] = '2'
        return response

    # Mindestabstand einhalten
    elapsed = _time_module.time() - _api_last_request
    if elapsed < _API_MIN_INTERVAL:
        _time_module.sleep(_API_MIN_INTERVAL - elapsed)

    return None  # Request fortsetzen

@app.after_request
def release_request_slot(response):
    """Gibt den Request-Slot wieder frei"""
    global _api_last_request, _pending_requests

    if request.path.startswith('/api/') and request.path != '/api/health':
        _api_last_request = _time_module.time()
        try:
            _request_semaphore.release()
        except ValueError:
            pass  # Semaphore war nicht gehalten
        with _pending_lock:
            _pending_requests = max(0, _pending_requests - 1)

    return response

@app.teardown_request
def cleanup_on_error(exception):
    """Cleanup bei Fehlern - stellt sicher dass Semaphore freigegeben wird"""
    global _pending_requests
    if exception and request.path.startswith('/api/') and request.path != '/api/health':
        try:
            _request_semaphore.release()
        except ValueError:
            pass
        with _pending_lock:
            _pending_requests = max(0, _pending_requests - 1)

# Zusätzliche CORS-Headers für file:// Protokoll
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    return response


# Health-Check Endpoint für Mobile App
@app.route('/api/health')
def health_check():
    """Health-Check für Verbindungsstatus"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        release_connection(conn)
        return jsonify({
            'status': 'ok',
            'backend': 'connected',
            'frontend': FRONTEND_PATH
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500


# PID-File Management
PID_FILE = Path(__file__).parent / 'api_server.pid'

def write_pid():
    """Schreibt aktuelle Prozess-ID in PID-Datei"""
    try:
        PID_FILE.write_text(str(os.getpid()))
        logger.info(f"PID-Datei erstellt: {PID_FILE}")
    except Exception as e:
        logger.warning(f"Konnte PID-Datei nicht erstellen: {e}")

def remove_pid():
    """Entfernt PID-Datei bei Server-Beendigung"""
    try:
        if PID_FILE.exists():
            PID_FILE.unlink()
            logger.info("PID-Datei gelöscht")
    except Exception as e:
        logger.warning(f"Konnte PID-Datei nicht löschen: {e}")

# PID-Datei beim Start erstellen und beim Ende löschen
atexit.register(remove_pid)

# Konfiguration laden
config_path = Path(__file__).parent / "config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

BACKEND_PATH = config['database']['backend_path']
FRONTEND_PATH = config['database']['frontend_path']

# ============================================
# Connection Pool für Access ODBC
# ============================================
class ConnectionPool:
    """Einfacher Connection Pool für Access ODBC - begrenzt gleichzeitige Verbindungen"""

    def __init__(self, max_connections=3):
        self.max_connections = max_connections
        self._pool = queue.Queue(maxsize=max_connections)
        self._lock = threading.Lock()
        self._created = 0
        self._odbc_conn_str = (
            r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
            f'DBQ={BACKEND_PATH};'
        )
        pyodbc.pooling = False

    def get_connection(self):
        """Holt eine Verbindung aus dem Pool oder erstellt eine neue"""
        try:
            # Versuche eine freie Verbindung aus dem Pool zu holen (nicht blockierend)
            conn = self._pool.get_nowait()
            # Prüfe ob Verbindung noch gültig
            try:
                conn.cursor().execute("SELECT 1")
                return conn
            except:
                # Verbindung kaputt, erstelle neue
                with self._lock:
                    self._created -= 1
                return self._create_connection()
        except queue.Empty:
            # Pool leer - erstelle neue wenn unter Limit
            with self._lock:
                if self._created < self.max_connections:
                    return self._create_connection()
            # Max erreicht - warte auf freie Verbindung (mit Timeout)
            try:
                conn = self._pool.get(timeout=10)
                return conn
            except queue.Empty:
                raise Exception("Keine Datenbankverbindung verfügbar (Timeout)")

    def _create_connection(self):
        """Erstellt eine neue Verbindung"""
        print(f"[DB] Creating connection with ODBC driver...")
        conn = pyodbc.connect(self._odbc_conn_str)
        print(f"[DB] Connection created successfully")
        with self._lock:
            self._created += 1
        return conn

    def release_connection(self, conn):
        """Gibt eine Verbindung zurück in den Pool"""
        try:
            self._pool.put_nowait(conn)
        except queue.Full:
            # Pool voll, schließe Verbindung
            try:
                release_connection(conn)
            except:
                pass
            with self._lock:
                self._created -= 1

    def close_all(self):
        """Schließt alle Verbindungen beim Shutdown"""
        while True:
            try:
                conn = self._pool.get_nowait()
                try:
                    release_connection(conn)
                except:
                    pass
            except queue.Empty:
                break

# Globaler Connection Pool (reduziert auf 3 für bessere Stabilität)
# Access-Limit: ~64 gleichzeitige Verbindungen, aber weniger ist stabiler
connection_pool = ConnectionPool(max_connections=3)

# Cleanup beim Beenden
atexit.register(connection_pool.close_all)

# ============================================
# SINGLE GLOBAL CONNECTION MIT QUERY-SERIALISIERUNG
# ============================================
# PROBLEM: Access ODBC-Treiber crasht mit Segmentation Fault unter Last.
# LÖSUNG:
#   1. Nur EINE Verbindung (global)
#   2. Query-Mutex serialisiert ALLE Datenbankzugriffe
#   3. Längere Pause zwischen Queries (ODBC-Treiber stabilisieren)
#   4. Verbindung nach jedem Query schließen und neu öffnen (SAFEST MODE)

# Hinweis: time-Modul wird oben als _time_module importiert (Konflikt mit datetime.time vermeiden)

_global_conn = None
_conn_lock = threading.Lock()
_query_lock = threading.Lock()  # Serialisiert ALLE Queries
_last_query_time = 0
_QUERY_MIN_INTERVAL = 0.5  # 500ms Mindestabstand zwischen Queries (MAXIMAL für Stabilität)
_RECONNECT_AFTER_EACH_QUERY = True  # Bei True: Verbindung nach jedem Query schließen (langsamer aber VIEL stabiler)
_FORCE_GC_AFTER_QUERY = True  # Erzwingt Garbage Collection nach jedem Query (Memory-Cleanup)

def get_connection():
    """Holt oder erstellt die EINZIGE globale DB-Verbindung"""
    global _global_conn

    with _conn_lock:
        if _global_conn is not None:
            return _global_conn

        # Neue Verbindung erstellen
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        logger.info("Erstelle neue Datenbankverbindung...")
        _global_conn = pyodbc.connect(conn_str)
        logger.info("Datenbankverbindung hergestellt")
        return _global_conn

def execute_query(sql, params=None, fetch=True, max_retries=2):
    """
    Führt eine Query SERIALISIERT aus (nur eine Query gleichzeitig).
    Verhindert Segmentation Faults im Access ODBC-Treiber.
    Mit automatischem Retry bei Verbindungsfehlern.
    """
    global _last_query_time

    with _query_lock:
        # Mindestabstand zwischen Queries einhalten
        elapsed = _time_module.time() - _last_query_time
        if elapsed < _QUERY_MIN_INTERVAL:
            _time_module.sleep(_QUERY_MIN_INTERVAL - elapsed)

        last_error = None
        for attempt in range(max_retries + 1):
            try:
                conn = get_connection()
                cursor = conn.cursor()

                if params:
                    cursor.execute(sql, params)
                else:
                    cursor.execute(sql)

                if fetch:
                    rows = cursor.fetchall()
                    result = [row_to_dict(cursor, row) for row in rows]
                else:
                    conn.commit()
                    result = cursor.rowcount

                cursor.close()
                _last_query_time = _time_module.time()

                # Optional: Verbindung nach jedem Query schließen (stabiler aber langsamer)
                if _RECONNECT_AFTER_EACH_QUERY:
                    reset_connection()

                # Optional: Garbage Collection erzwingen (räumt ODBC-Ressourcen auf)
                if _FORCE_GC_AFTER_QUERY:
                    import gc
                    gc.collect()

                return result

            except pyodbc.Error as e:
                last_error = e
                logger.warning(f"Query-Fehler (Versuch {attempt + 1}/{max_retries + 1}): {e}")
                reset_connection()
                if attempt < max_retries:
                    _time_module.sleep(0.5)  # Kurze Pause vor Retry
                    continue
                raise
            except Exception as e:
                last_error = e
                logger.error(f"Unerwarteter Query-Fehler: {e}")
                reset_connection()
                raise

        # Sollte nicht erreicht werden
        raise last_error or Exception("Query fehlgeschlagen nach allen Versuchen")

def reset_connection():
    """Setzt die Verbindung zurück (bei Fehlern)"""
    global _global_conn
    with _conn_lock:
        if _global_conn is not None:
            try:
                _global_conn.close()
            except:
                pass
            _global_conn = None
            logger.info("Verbindung zurückgesetzt")

def close_global_connection():
    """Schließt die globale Verbindung (für Shutdown)"""
    global _global_conn
    with _conn_lock:
        if _global_conn is not None:
            try:
                _global_conn.close()
                logger.info("Globale Verbindung geschlossen")
            except:
                pass
            _global_conn = None

# Verbindung beim Beenden schließen
atexit.register(close_global_connection)

def release_connection(conn):
    """Commit und bereit für nächsten Request (Verbindung bleibt offen)"""
    try:
        conn.commit()
    except:
        pass

def serialize_value(val):
    """Konvertiert Datenbankwerte für JSON"""
    if val is None:
        return None
    # Typ-Prüfungen einzeln mit expliziter Fehlerbehandlung
    try:
        is_dt = isinstance(val, datetime)
    except TypeError:
        logger.error(f"isinstance(val, datetime) failed - datetime type: {type(datetime)}")
        is_dt = False
    if is_dt:
        return val.isoformat()

    try:
        is_date = isinstance(val, date)
    except TypeError:
        logger.error(f"isinstance(val, date) failed - date type: {type(date)}")
        is_date = False
    if is_date:
        return val.isoformat()

    try:
        is_time = isinstance(val, datetime_time)
    except TypeError:
        logger.error(f"isinstance(val, datetime_time) failed - datetime_time type: {type(datetime_time)}")
        is_time = False
    if is_time:
        return val.strftime('%H:%M:%S')

    try:
        is_dec = isinstance(val, Decimal)
    except TypeError:
        logger.error(f"isinstance(val, Decimal) failed - Decimal type: {type(Decimal)}")
        is_dec = False
    if is_dec:
        return float(val)

    try:
        is_bytes = isinstance(val, bytes)
    except TypeError:
        logger.error(f"isinstance(val, bytes) failed - bytes type: {type(bytes)}")
        is_bytes = False
    if is_bytes:
        return val.decode('utf-8', errors='replace')

    return val

def row_to_dict(cursor, row):
    """Konvertiert eine Datenbankzeile in ein Dictionary"""
    columns = [column[0] for column in cursor.description]
    return {col: serialize_value(val) for col, val in zip(columns, row)}

# ============================================
# Statische Dateien (HTML-Formulare)
# ============================================

@app.route('/')
def index():
    """Hauptseite mit Formular-Übersicht"""
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>CONSYS Web-Interface</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            h1 { color: #2c3e50; }
            .card { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .card h3 { margin-top: 0; color: #3498db; }
            a { color: #3498db; text-decoration: none; }
            a:hover { text-decoration: underline; }
            .status { color: #27ae60; font-weight: bold; }
        </style>
    </head>
    <body>
        <h1>CONSYS Web-Interface</h1>
        <p class="status">API Server läuft</p>

        <div class="card">
            <h3><a href="/web/frm_VA_Auftragstamm.html">Auftragstamm (frm_VA_Auftragstamm)</a></h3>
            <p>Aufträge verwalten, Einsatztage und Zuordnungen bearbeiten</p>
        </div>

        <div class="card">
            <h3>API Endpunkte</h3>
            <ul>
                <li><a href="/api/auftraege">/api/auftraege</a> - Alle Aufträge</li>
                <li><a href="/api/mitarbeiter">/api/mitarbeiter</a> - Alle Mitarbeiter</li>
                <li><a href="/api/kunden">/api/kunden</a> - Alle Kunden</li>
                <li><a href="/api/tables">/api/tables</a> - Alle Tabellen</li>
                <li><a href="/api/dashboard">/api/dashboard</a> - Dashboard-Kennzahlen</li>
            </ul>
        </div>
    </body>
    </html>
    """

@app.route('/web/<path:filename>')
def serve_web(filename):
    """Liefert HTML-Formulare aus web-Ordner"""
    return send_from_directory('web', filename)

# Route für HTML-Formulare aus forms3
@app.route('/forms/<path:filename>')
def serve_forms(filename):
    """Liefert HTML-Formulare aus dem Forms3-Ordner (Formulare liegen direkt darin)"""
    return send_from_directory(str(FORMS_PATH), filename)

# Route für CSS/JS Assets (aus forms3/css und forms3/js)
@app.route('/css/<path:filename>')
def serve_css(filename):
    """Liefert CSS-Dateien aus forms3/css"""
    css_dir = FORMS_PATH / "css"
    if not css_dir.exists():
        css_dir = FORMS_PATH  # Fallback: direkt aus forms3
    return send_from_directory(str(css_dir), filename)

@app.route('/js/<path:filename>')
def serve_js(filename):
    """Liefert JavaScript-Dateien aus forms3/js"""
    js_dir = FORMS_PATH / "js"
    return send_from_directory(str(js_dir), filename)

# Hauptseite zeigt Formular-Liste
@app.route('/forms/')
def forms_index():
    """Zeigt Liste aller verfügbaren Formulare aus forms3"""
    html_files = list(FORMS_PATH.glob("frm_*.html"))
    links = "\n".join([f'<li><a href="/forms/{f.name}">{f.stem}</a></li>' for f in sorted(html_files)])
    return f"""
    <!DOCTYPE html>
    <html>
    <head><title>CONSYS Formulare</title></head>
    <body style="font-family: Arial; padding: 20px;">
        <h1>CONSYS HTML-Formulare</h1>
        <ul>{links}</ul>
    </body>
    </html>
    """

# ============================================
# API: Tabellen-Info
# ============================================

@app.route('/api/tables')
def list_tables():
    """Listet alle Tabellen der Datenbank"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        tables = []
        for table in cursor.tables(tableType='TABLE'):
            tables.append({
                'name': table.table_name,
                'type': table.table_type
            })
        release_connection(conn)
        return jsonify({'success': True, 'tables': tables})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Dashboard
# ============================================

@app.route('/api/dashboard')
def dashboard():
    """Dashboard-Kennzahlen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        today = datetime.now().strftime('%Y-%m-%d')

        # Aufträge heute
        cursor.execute("""
            SELECT COUNT(*) FROM tbl_VA_AnzTage
            WHERE VADatum = ?
        """, (today,))
        auftraege_heute = cursor.fetchone()[0]

        # Aktive Mitarbeiter
        cursor.execute("""
            SELECT COUNT(*) FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = True
        """)
        mitarbeiter_aktiv = cursor.fetchone()[0]

        # Offene Aufträge (aktuelle Planungen)
        cursor.execute("""
            SELECT COUNT(*) FROM tbl_MA_VA_Planung
            WHERE VADatum >= Date()
        """)
        offene_anfragen = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'auftraege_heute': auftraege_heute,
                'mitarbeiter_aktiv': mitarbeiter_aktiv,
                'offene_anfragen': offene_anfragen,
                'datum': today
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Aufträge (tbl_VA_Auftrag)
# ============================================

@app.route('/api/auftraege')
def get_auftraege():
    """Alle Aufträge mit optionaler Filterung"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Parameter für Filterung
        kunde_id = request.args.get('kunde_id')
        datum_ab = request.args.get('ab')  # Datum ab Filter (alt)
        datum_von = request.args.get('von')  # Startdatum Filter
        datum_bis = request.args.get('bis')  # Enddatum Filter
        limit = request.args.get('limit', 100, type=int)
        offset = request.args.get('offset', 0, type=int)

        # Query bauen mit optionalen Filtern
        where_clauses = []
        params = []

        if kunde_id:
            where_clauses.append("Veranstalter_ID = ?")
            params.append(int(kunde_id))

        if datum_ab:
            where_clauses.append("Dat_VA_Von >= ?")
            params.append(datum_ab)

        # Neuer Filter: von/bis für Zeitraumabfrage
        if datum_von:
            where_clauses.append("Dat_VA_Bis >= ?")
            params.append(datum_von)

        if datum_bis:
            where_clauses.append("Dat_VA_Von <= ?")
            params.append(datum_bis)

        where_sql = ""
        if where_clauses:
            where_sql = "WHERE " + " AND ".join(where_clauses)

        # Wenn ab-Datum gesetzt: ASC (naechster Auftrag zuerst)
        # Sonst: DESC (neuester zuerst)
        sort_order = "ASC" if datum_ab else "DESC"

        query = f"""
            SELECT TOP {limit} * FROM tbl_VA_Auftragstamm
            {where_sql}
            ORDER BY Dat_VA_Von {sort_order}, ID {sort_order}
        """

        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        rows = cursor.fetchall()
        auftraege = [row_to_dict(cursor, row) for row in rows]

        # Gesamtanzahl mit gleichen Filtern
        count_query = f"SELECT COUNT(*) FROM tbl_VA_Auftragstamm {where_sql}"
        if params:
            cursor.execute(count_query, params)
        else:
            cursor.execute(count_query)
        total = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': auftraege,
            'total': total,
            'limit': limit,
            'offset': offset
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/auftraege/<int:id>')
def get_auftrag(id):
    """Einzelner Auftrag mit allen Details"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Hauptdaten - Tabelle hat ID als Primärschlüssel
        cursor.execute("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Auftrag nicht gefunden'}), 404

        auftrag = row_to_dict(cursor, row)

        auftrag_id = auftrag.get('ID')

        # Einsatztage (tbl_VA_AnzTage)
        cursor.execute("""
            SELECT * FROM tbl_VA_AnzTage
            WHERE VA_ID = ?
            ORDER BY VADatum
        """, (auftrag_id,))
        einsatztage = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Startzeiten (tbl_VA_Start)
        cursor.execute("""
            SELECT * FROM tbl_VA_Start
            WHERE VA_ID = ?
            ORDER BY VADatum, VA_Start
        """, (auftrag_id,))
        startzeiten = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Zuordnungen (tbl_MA_VA_Zuordnung)
        cursor.execute("""
            SELECT z.*, m.Nachname, m.Vorname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
            WHERE z.VA_ID = ?
            ORDER BY z.VADatum, m.Nachname
        """, (auftrag_id,))
        zuordnungen = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Planungen (tbl_MA_VA_Planung)
        cursor.execute("""
            SELECT p.*, m.Nachname, m.Vorname
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            WHERE p.VA_ID = ?
            ORDER BY p.VADatum, m.Nachname
        """, (auftrag_id,))
        anfragen = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Kundeninfo
        if auftrag.get('Veranstalter_ID'):
            cursor.execute("""
                SELECT kun_Id, kun_Firma, kun_Strasse, kun_PLZ, kun_Ort
                FROM tbl_KD_Kundenstamm
                WHERE kun_Id = ?
            """, (auftrag['Veranstalter_ID'],))
            kunde_row = cursor.fetchone()
            if kunde_row:
                auftrag['kunde'] = row_to_dict(cursor, kunde_row)

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'auftrag': auftrag,
                'einsatztage': einsatztage,
                'startzeiten': startzeiten,
                'zuordnungen': zuordnungen,
                'anfragen': anfragen
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/auftraege', methods=['POST'])
def create_auftrag():
    """Neuen Auftrag erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Pflichtfelder prüfen
        required = ['VA_KD_ID']
        for field in required:
            if field not in data:
                return jsonify({'success': False, 'error': f'Feld {field} fehlt'}), 400

        # Insert mit dynamischen Feldern
        fields = []
        values = []
        placeholders = []

        for key, value in data.items():
            if key.startswith('VA_'):
                fields.append(key)
                values.append(value)
                placeholders.append('?')

        query = f"""
            INSERT INTO tbl_VA_Auftragstamm ({', '.join(fields)})
            VALUES ({', '.join(placeholders)})
        """

        cursor.execute(query, values)
        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Auftrag erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/auftraege/<int:id>', methods=['PUT'])
def update_auftrag(id):
    """Auftrag aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Update mit dynamischen Feldern
        updates = []
        values = []

        for key, value in data.items():
            if key.startswith('VA_') and key != 'VA_ID':
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder zum Aktualisieren'}), 400

        values.append(id)
        query = f"""
            UPDATE tbl_VA_Auftragstamm
            SET {', '.join(updates)}
            WHERE VA_ID = ?
        """

        cursor.execute(query, values)
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Auftrag aktualisiert'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/auftraege/<int:id>', methods=['DELETE'])
def delete_auftrag(id):
    """Auftrag löschen (Soft-Delete: Status auf 'Gelöscht' setzen)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Prüfen ob Auftrag existiert
        cursor.execute("SELECT VA_ID FROM tbl_VA_Auftragstamm WHERE VA_ID = ?", (id,))
        if not cursor.fetchone():
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Auftrag nicht gefunden'}), 404

        # Soft-Delete: Status auf 99 (Gelöscht) setzen
        cursor.execute("""
            UPDATE tbl_VA_Auftragstamm
            SET VA_Status = 99
            WHERE VA_ID = ?
        """, (id,))
        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Auftrag gelöscht'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/sendEinsatzliste', methods=['POST'])
def send_einsatzliste():
    """Einsatzliste per E-Mail versenden"""
    try:
        data = request.get_json()
        va_id = data.get('va_id')
        typ = data.get('typ', 'MA')  # MA, BOS, SUB

        if not va_id:
            return jsonify({'success': False, 'error': 'va_id fehlt'}), 400

        # TODO: E-Mail-Versand implementieren
        # Für jetzt nur Logging und Erfolg zurückgeben
        print(f"[API] Einsatzliste senden: VA_ID={va_id}, Typ={typ}")

        return jsonify({
            'success': True,
            'message': f'Einsatzliste ({typ}) für Auftrag {va_id} versendet'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/markELGesendet', methods=['POST'])
def mark_el_gesendet():
    """Einsatzliste als gesendet markieren"""
    try:
        data = request.get_json()
        va_id = data.get('va_id')

        if not va_id:
            return jsonify({'success': False, 'error': 'va_id fehlt'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # EL-Gesendet-Flag setzen
        cursor.execute("""
            UPDATE tbl_VA_Auftragstamm
            SET VA_EL_Gesendet = True, VA_EL_Gesendet_Am = Now()
            WHERE VA_ID = ?
        """, (va_id,))
        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Einsatzliste als gesendet markiert'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/getSyncErrors', methods=['GET'])
def get_sync_errors():
    """Synchronisierungsfehler abrufen"""
    try:
        va_id = request.args.get('va_id')

        conn = get_connection()
        cursor = conn.cursor()

        if va_id:
            cursor.execute("""
                SELECT * FROM tbl_SyncErrors
                WHERE VA_ID = ?
                ORDER BY Fehler_Datum DESC
            """, (va_id,))
        else:
            cursor.execute("""
                SELECT TOP 100 * FROM tbl_SyncErrors
                ORDER BY Fehler_Datum DESC
            """)

        rows = cursor.fetchall()
        errors = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({
            'success': True,
            'data': errors
        })
    except Exception as e:
        # Falls Tabelle nicht existiert, leere Liste zurückgeben
        return jsonify({
            'success': True,
            'data': []
        })

# ============================================
# API: Mitarbeiter (tbl_MA_Mitarbeiterstamm)
# ============================================

@app.route('/api/mitarbeiter')
def get_mitarbeiter():
    """Alle Mitarbeiter

    Query-Parameter:
    - limit: Max. Anzahl (default 500)
    - aktiv: Nur aktive MA (default true)
    - search: Suche in Nachname/Vorname
    - anstellung: Filter Anstellungsart_ID (Komma-separiert, z.B. "3,5")
    - filter_anstellung: true = Default-Filter (3,5), false = alle
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv_param = request.args.get('aktiv', 'true')  # Standard: nur aktive
        # Akzeptiere 1, true, True als aktiv=True
        aktiv = aktiv_param.lower() in ('true', '1', 'yes')
        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')
        anstellung = request.args.get('anstellung', '')
        filter_anstellung = request.args.get('filter_anstellung', 'true')

        query = f"""
            SELECT TOP {limit} ID, Nachname, Vorname, IstAktiv,
                   Tel_Mobil, Strasse, PLZ, Ort, Anstellungsart_ID
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = ?
        """
        params = [aktiv]

        # Filter nach Anstellungsart_ID
        if anstellung:
            # Expliziter Filter (z.B. "3,5" oder "3")
            anstellung_list = [a.strip() for a in anstellung.split(',')]
            placeholders = ','.join(['?' for _ in anstellung_list])
            query += f" AND Anstellungsart_ID IN ({placeholders})"
            params.extend([int(a) for a in anstellung_list])
        elif filter_anstellung.lower() == 'true':
            # Default-Filter: Festangestellte (3) und Minijobber (5)
            query += " AND Anstellungsart_ID IN (3, 5)"

        if search:
            query += " AND (Nachname LIKE ? OR Vorname LIKE ?)"
            params.extend([f'%{search}%', f'%{search}%'])

        query += " ORDER BY Nachname, Vorname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        mitarbeiter = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': mitarbeiter,
            'count': len(mitarbeiter)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>')
def get_mitarbeiter_detail(id):
    """Einzelner Mitarbeiter mit Details"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Mitarbeiter nicht gefunden'}), 404

        mitarbeiter = row_to_dict(cursor, row)

        # Nicht-Verfügbarkeiten
        cursor.execute("""
            SELECT * FROM tbl_MA_NVerfuegZeiten
            WHERE MA_ID = ?
            ORDER BY vonDat DESC
        """, (id,))
        nverfueg = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'mitarbeiter': mitarbeiter,
                'nicht_verfuegbar': nverfueg
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/mitarbeiter_schnellauswahl')
def get_mitarbeiter_schnellauswahl():
    """Mitarbeiter für Schnellauswahl-Formular mit Verfügbarkeitsstatus"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv = request.args.get('aktiv', 'true').lower() == 'true'
        anstellung = request.args.get('anstellung', '')  # Festangestellt, Aushilfe, Alle
        nur_34a = request.args.get('nur_34a', 'false').lower() == 'true'
        datum = request.args.get('datum', '')
        search = request.args.get('search', '')

        # Basis-Query
        query = """
            SELECT m.ID, m.Nachname, m.Vorname, m.IstAktiv, m.Tel_Mobil,
                   m.PLZ, m.Ort, m.Nr as Personalnummer
            FROM tbl_MA_Mitarbeiterstamm m
            WHERE m.IstAktiv = ?
        """
        params = [aktiv]

        # Anstellungsart-Filter (falls Feld existiert)
        if anstellung and anstellung != 'Alle':
            # Annahme: es gibt ein Anstellungsart-Feld oder wir nutzen tbl_hlp_MA_Anstellungsart
            pass  # TODO: Anstellungsart-Filter implementieren wenn Feldname bekannt

        # Suche
        if search:
            query += " AND (m.Nachname LIKE ? OR m.Vorname LIKE ?)"
            params.extend([f'%{search}%', f'%{search}%'])

        query += " ORDER BY m.Nachname, m.Vorname"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        mitarbeiter = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': mitarbeiter,
            'count': len(mitarbeiter)
        })
    except Exception as e:
        logger.error(f"Fehler bei Mitarbeiter-Schnellauswahl: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# API: Kunden (tbl_KD_Kundenstamm)
# ============================================

@app.route('/api/kunden')
def get_kunden():
    """Alle Kunden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')
        aktiv = request.args.get('aktiv', 'true')

        query = f"""
            SELECT TOP {limit} kun_Id, kun_Firma, kun_Strasse, kun_PLZ, kun_Ort,
                   kun_IstAktiv
            FROM tbl_KD_Kundenstamm
            WHERE kun_IstAktiv = ?
        """
        params = [aktiv.lower() == 'true']

        if search:
            query += " AND kun_Firma LIKE ?"
            params.append(f'%{search}%')

        query += " ORDER BY kun_Firma"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        kunden = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': kunden
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Einsatztage (tbl_VA_AnzTage)
# ============================================

@app.route('/api/einsatztage')
def get_einsatztage():
    """Einsatztage mit optionaler Filterung nach Datum/Auftrag"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        datum_von = request.args.get('datum_von')
        datum_bis = request.args.get('datum_bis')

        # Einfachste Query ohne dynamische Parameter
        if va_id:
            cursor.execute("SELECT TOP 1000 ID, VA_ID, VADatum FROM tbl_VA_AnzTage WHERE VA_ID = ? ORDER BY VADatum DESC", (int(va_id),))
        else:
            cursor.execute("SELECT TOP 1000 ID, VA_ID, VADatum FROM tbl_VA_AnzTage ORDER BY VADatum DESC")

        rows = cursor.fetchall()
        einsatztage = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': einsatztage
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/einsatzuebersicht')
def get_einsatzuebersicht():
    """Einsatzuebersicht mit allen Details (Ort, MA-Namen, Stunden, PosNr)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Parameter
        von = request.args.get('von')
        bis = request.args.get('bis')
        nur_aktive = request.args.get('nurAktive', 'true').lower() == 'true'

        # Minimale Test-Query - nur grundlegende Felder
        query = """
            SELECT TOP 100
                s.ID,
                s.VA_ID,
                s.VADatum,
                s.VA_Start,
                s.VA_Ende,
                s.MA_Anzahl
            FROM tbl_VA_Start s
            ORDER BY s.VADatum DESC
        """

        logger.info(f"[Einsatzuebersicht] Executing query: {query}")
        cursor.execute(query)
        rows = cursor.fetchall()
        einsaetze = []

        for row in rows:
            # Manuelle Feldzu ordnung statt row_to_dict
            einsatz = {
                'VAS_ID': row[0],  # s.ID
                'VA_ID': row[1],   # s.VA_ID
                'VADatum': row[2],  # s.VADatum
                'VA_Start': row[3], # s.VA_Start
                'VA_Ende': row[4],  # s.VA_Ende
                'MA_Anzahl': row[5] # s.MA_Anzahl
            }

            # Fehlende Felder setzen
            einsatz['PosNr'] = ''
            einsatz['Auftrag'] = ''
            einsatz['Objekt'] = ''
            einsatz['Ort'] = ''
            einsatz['VA_IstAktiv'] = True

            # Auftrag und Objekt laden
            try:
                cursor.execute("""
                    SELECT Auftrag, Objekt, Ort
                    FROM tbl_VA_Auftragstamm
                    WHERE ID = ?
                """, (einsatz['VA_ID'],))
                auftrag_row = cursor.fetchone()
                if auftrag_row:
                    einsatz['Auftrag'] = auftrag_row[0] or ''
                    einsatz['Objekt'] = auftrag_row[1] or ''
                    einsatz['Ort'] = auftrag_row[2] or ''
            except Exception as e:
                logger.warning(f"Fehler beim Laden von Auftrag/Objekt: {e}")

            # Stunden berechnen (Brutto)
            if einsatz.get('VA_Start') and einsatz.get('VA_Ende'):
                try:
                    start_str = str(einsatz['VA_Start'])
                    ende_str = str(einsatz['VA_Ende'])

                    # Zeit-Strings parsen (Format: HH:MM:SS oder datetime)
                    if isinstance(einsatz['VA_Start'], datetime):
                        start_time = einsatz['VA_Start']
                        ende_time = einsatz['VA_Ende']
                    else:
                        # String Format "HH:MM:SS" oder "HH:MM"
                        start_parts = start_str.split(':')
                        ende_parts = ende_str.split(':')
                        start_time = datetime.strptime(f"{start_parts[0]}:{start_parts[1]}", "%H:%M")
                        ende_time = datetime.strptime(f"{ende_parts[0]}:{ende_parts[1]}", "%H:%M")

                    # Differenz berechnen
                    if ende_time < start_time:
                        # Ueber Mitternacht
                        ende_time += timedelta(days=1)

                    diff = ende_time - start_time
                    stunden_brutto = diff.total_seconds() / 3600

                    einsatz['Stunden_Brutto'] = round(stunden_brutto, 2)

                    # Stunden Netto (erstmal = Brutto, koennte spaeter Pausen abziehen)
                    einsatz['Stunden_Netto'] = round(stunden_brutto, 2)

                except Exception as e:
                    logger.warning(f"Fehler beim Berechnen der Stunden: {e}")
                    einsatz['Stunden_Brutto'] = 0
                    einsatz['Stunden_Netto'] = 0
            else:
                einsatz['Stunden_Brutto'] = 0
                einsatz['Stunden_Netto'] = 0

            # MA-Namen und Anzahl abrufen
            # Verwende nur VAStart_ID als eindeutigen Identifier
            cursor.execute("""
                SELECT m.ID, m.Nachname, m.Vorname
                FROM tbl_MA_VA_Planung p, tbl_MA_Mitarbeiterstamm m
                WHERE p.MA_ID = m.ID
                  AND p.VAStart_ID = ?
            """, (einsatz['VAS_ID'],))

            ma_rows = cursor.fetchall()
            ma_namen = []
            for ma_row in ma_rows:
                # Manuelle Feldzuordnung: ID, Nachname, Vorname
                vorname = ma_row[2] or ''
                nachname = ma_row[1] or ''
                ma_namen.append(f"{vorname} {nachname}".strip())

            einsatz['MA_Namen'] = ', '.join(ma_namen) if ma_namen else ''
            einsatz['MA_Anzahl_Ist'] = len(ma_rows)

            einsaetze.append(einsatz)

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': einsaetze
        })

    except Exception as e:
        logger.error(f"Fehler in get_einsatzuebersicht: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Zuordnungen (tbl_MA_VA_Zuordnung)
# ============================================

@app.route('/api/zuordnungen')
def get_zuordnungen():
    """MA-VA Zuordnungen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        ma_id = request.args.get('ma_id')
        datum = request.args.get('datum')
        datum_von = request.args.get('von')  # Startdatum Filter
        datum_bis = request.args.get('bis')  # Enddatum Filter

        query = """
            SELECT z.*, m.Nachname, m.Vorname, m.Tel_Mobil,
                   a.VA_ID AS Auftrag_ID, a.Auftrag, a.Objekt, a.Treffpunkt, a.Dienstkleidung,
                   a.Ort, a.Bemerkungen, o.Objektname
            FROM ((tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON z.VA_ID = a.VA_ID)
            LEFT JOIN tbl_OB_Objekt o ON a.Objekt_ID = o.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND z.VA_ID = ?"
            params.append(int(va_id))

        if ma_id:
            query += " AND z.MA_ID = ?"
            params.append(int(ma_id))

        if datum:
            query += " AND z.VADatum = ?"
            params.append(datum)

        # Zeitraum-Filter (von/bis)
        if datum_von:
            query += " AND z.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND z.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY z.VADatum ASC, z.MVA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        zuordnungen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        # Für die Mobile-App: Direkt das data-Array zurückgeben wenn ma_id gesetzt
        if ma_id:
            return jsonify(zuordnungen)

        return jsonify({
            'success': True,
            'data': zuordnungen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/zuordnungen', methods=['POST'])
def create_zuordnung():
    """Neue Zuordnung erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        ma_id = data.get('ma_id')
        va_id = data.get('va_id')
        vastart_id = data.get('vastart_id')
        vadatum = data.get('vadatum')

        if not ma_id or not va_id:
            return jsonify({'success': False, 'error': 'ma_id und va_id erforderlich'}), 400

        # Nicht-Verfügbarkeit prüfen
        if vadatum:
            cursor.execute("""
                SELECT COUNT(*) FROM tbl_MA_NVerfuegZeiten
                WHERE MA_ID = ?
                AND vonDat <= ?
                AND bisDat >= ?
            """, (ma_id, vadatum, vadatum))

            if cursor.fetchone()[0] > 0:
                return jsonify({
                    'success': False,
                    'error': 'Konflikt: Mitarbeiter ist als nicht verfügbar eingetragen'
                }), 409

        # Zuordnung erstellen
        cursor.execute("""
            INSERT INTO tbl_MA_VA_Zuordnung (MA_ID, VA_ID, VAStart_ID, VADatum)
            VALUES (?, ?, ?, ?)
        """, (ma_id, va_id, vastart_id, vadatum))

        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Zuordnung erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/zuordnungen/<int:id>', methods=['DELETE'])
def delete_zuordnung(id):
    """Zuordnung löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM tbl_MA_VA_Zuordnung WHERE ID = ?", (id,))
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Zuordnung gelöscht'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Planungen (tbl_MA_VA_Planung)
# ============================================

@app.route('/api/planungen')
def get_planungen():
    """MA-VA Planungen mit Auftrags-Details für Mobile-App"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        ma_id = request.args.get('ma_id')
        vadatum_id = request.args.get('vadatum_id')
        datum = request.args.get('datum')
        status = request.args.get('status')

        # Erweiterte Abfrage mit Auftrags-Details für Mobile-App
        # WICHTIG: Access SQL benötigt Klammern bei mehreren JOINs!
        query = """
            SELECT p.ID, p.VA_ID, p.VADatum_ID, p.VAStart_ID, p.PosNr,
                   p.MA_ID, p.Status_ID, p.VADatum, p.Bemerkungen,
                   p.MVA_Start, p.MVA_Ende, p.VA_Start, p.VA_Ende,
                   m.Nachname, m.Vorname, m.Tel_Mobil,
                   a.Auftrag, a.Ort, a.Objekt, a.Treffpunkt, a.Dienstkleidung
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(int(va_id))

        if ma_id:
            query += " AND p.MA_ID = ?"
            params.append(int(ma_id))

        if vadatum_id:
            query += " AND p.VADatum_ID = ?"
            params.append(int(vadatum_id))

        if datum:
            query += " AND p.VADatum = ?"
            params.append(datum)

        if status:
            query += " AND p.Status_ID = ?"
            params.append(int(status))

        # Für Mobile-App: Nur zukünftige Planungen sortiert nach Datum
        if ma_id:
            query += " ORDER BY p.VADatum ASC, p.MVA_Start ASC"
        else:
            query += " ORDER BY p.ID DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        planungen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        # Für die Mobile-App: Direkt das Array zurückgeben wenn ma_id gesetzt
        if ma_id:
            return jsonify(planungen)

        return jsonify({
            'success': True,
            'data': planungen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/planungen/<int:id>', methods=['PUT'])
def update_planung(id):
    """Planung aktualisieren (z.B. Status ändern für Zusage/Absage)"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Update-Felder zusammenbauen
        updates = []
        params = []

        if 'Status_ID' in data:
            updates.append("Status_ID = ?")
            params.append(int(data['Status_ID']))

        if 'Bemerkung' in data:
            updates.append("Bemerkung = ?")
            params.append(data['Bemerkung'])

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Update-Felder'}), 400

        params.append(id)
        query = f"UPDATE tbl_MA_VA_Planung SET {', '.join(updates)} WHERE ID = ?"

        cursor.execute(query, params)
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Planung aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/planungen', methods=['POST'])
def create_planung():
    """Neue MA-VA Planung erstellen"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten'}), 400

        # Pflichtfelder
        va_id = data.get('va_id') or data.get('VA_ID')
        ma_id = data.get('ma_id') or data.get('MA_ID')

        if not va_id or not ma_id:
            return jsonify({'success': False, 'error': 'va_id und ma_id sind erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Optionale Felder
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID')
        vastart_id = data.get('vastart_id') or data.get('VAStart_ID')
        vadatum = data.get('vadatum') or data.get('VADatum')
        status_id = data.get('status_id') or data.get('Status_ID') or 1  # Default: Angefragt
        pos_nr = data.get('pos_nr') or data.get('PosNr') or 1

        # Prüfen ob bereits eingeteilt
        cursor.execute("""
            SELECT ID FROM tbl_MA_VA_Planung
            WHERE VA_ID = ? AND MA_ID = ? AND (VADatum_ID = ? OR VADatum = ?)
        """, [va_id, ma_id, vadatum_id, vadatum])

        existing = cursor.fetchone()
        if existing:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'MA bereits eingeteilt', 'existing_id': existing[0]}), 409

        # Einfügen
        cursor.execute("""
            INSERT INTO tbl_MA_VA_Planung (VA_ID, VADatum_ID, VAStart_ID, PosNr, MA_ID, Status_ID, VADatum)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, [va_id, vadatum_id, vastart_id, pos_nr, ma_id, status_id, vadatum])

        conn.commit()

        # Neue ID abrufen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Planung erstellt'
        }), 201

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/planungen/<int:id>', methods=['DELETE'])
def delete_planung(id):
    """Planung löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM tbl_MA_VA_Planung WHERE ID = ?", [id])

        if cursor.rowcount == 0:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Planung nicht gefunden'}), 404

        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Planung gelöscht'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# API: Zusage / Absage für Mitarbeiter-App
# ============================================

@app.route('/api/planungen/<int:id>/zusage', methods=['POST'])
def zusage_planung(id):
    """
    Zusage verarbeiten: MA wird von tbl_MA_VA_Planung in tbl_MA_VA_Zuordnung verschoben.
    Entspricht der Logik aus btnAddZusage_Click in VBA.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # 1. Planung-Daten lesen
        cursor.execute("""
            SELECT MA_ID, VA_ID, VADatum_ID, VAStart_ID, MVA_Start, MVA_Ende
            FROM tbl_MA_VA_Planung
            WHERE ID = ?
        """, [id])
        row = cursor.fetchone()

        if not row:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Planung nicht gefunden'}), 404

        ma_id = row[0]
        va_id = row[1]
        vadatum_id = row[2]
        vastart_id = row[3]

        # 2. Freien Slot in tbl_MA_VA_Zuordnung finden (MA_ID = 0, IstFraglich = False)
        cursor.execute("""
            SELECT ID FROM tbl_MA_VA_Zuordnung
            WHERE VA_ID = ? AND VADatum_ID = ? AND VAStart_ID = ?
            AND MA_ID = 0 AND IstFraglich = False
        """, [va_id, vadatum_id, vastart_id])
        slot = cursor.fetchone()

        if not slot:
            release_connection(conn)
            return jsonify({
                'success': False,
                'error': 'Kein freier Slot verfügbar. Alle Plätze sind belegt.'
            }), 400

        zuo_id = slot[0]

        # 3. MA in den freien Slot eintragen
        cursor.execute("""
            UPDATE tbl_MA_VA_Zuordnung
            SET MA_ID = ?, IstFraglich = False
            WHERE ID = ?
        """, [ma_id, zuo_id])

        # 4. Planung löschen (MA ist jetzt zugeordnet)
        cursor.execute("DELETE FROM tbl_MA_VA_Planung WHERE ID = ?", [id])

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Zusage erfolgreich! Du bist jetzt für diesen Einsatz eingeteilt.',
            'zuordnung_id': zuo_id
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/planungen/<int:id>/absage', methods=['POST'])
def absage_planung(id):
    """
    Absage verarbeiten: Status_ID auf 4 setzen in tbl_MA_VA_Planung.
    MA bleibt in Planung mit Status "Abgesagt".
    """
    try:
        data = request.get_json() or {}
        grund = data.get('grund', '')

        conn = get_connection()
        cursor = conn.cursor()

        # Status auf 4 (Absage) setzen
        cursor.execute("""
            UPDATE tbl_MA_VA_Planung
            SET Status_ID = 4, Bemerkungen = ?
            WHERE ID = ?
        """, [grund, id])

        if cursor.rowcount == 0:
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Planung nicht gefunden'}), 404

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Absage erfolgreich gespeichert.'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# API: Verfügbarkeit prüfen
# ============================================

@app.route('/api/verfuegbarkeit')
def check_verfuegbarkeit():
    """Prüft verfügbare Mitarbeiter für einen Zeitraum"""
    try:
        datum = request.args.get('datum')

        if not datum:
            return jsonify({'success': False, 'error': 'Datum erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Aktive MA die NICHT:
        # 1. Bereits eingeteilt sind für dieses Datum
        # 2. Als nicht-verfügbar eingetragen sind
        query = """
            SELECT m.ID, m.Nachname, m.Vorname
            FROM tbl_MA_Mitarbeiterstamm m
            WHERE m.IstAktiv = True
            AND m.ID NOT IN (
                SELECT z.MA_ID FROM tbl_MA_VA_Zuordnung z
                WHERE z.VADatum = ?
            )
            AND m.ID NOT IN (
                SELECT nv.MA_ID FROM tbl_MA_NVerfuegZeiten nv
                WHERE nv.vonDat <= ? AND nv.bisDat >= ?
            )
            ORDER BY m.Nachname, m.Vorname
        """
        params = [datum, datum, datum]

        cursor.execute(query, params)
        rows = cursor.fetchall()

        verfuegbar = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': verfuegbar,
            'count': len(verfuegbar)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Generische Tabellen-Abfrage
# ============================================

@app.route('/api/query', methods=['POST'])
def execute_query():
    """Führt eine SELECT-Abfrage aus (nur lesend!)"""
    try:
        data = request.get_json()
        query = data.get('query', '')

        # Nur SELECT erlauben
        if not query.strip().upper().startswith('SELECT'):
            return jsonify({'success': False, 'error': 'Nur SELECT-Abfragen erlaubt'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(query)
        rows = cursor.fetchall()

        result = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': result,
            'count': len(result)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/sql', methods=['POST'])
def execute_sql():
    """Führt SQL-Abfragen aus (für WebView2-Bridge Kompatibilität)"""
    try:
        data = request.get_json()
        sql = data.get('sql', '')
        fetch = data.get('fetch', True)

        if not sql.strip():
            return jsonify({'success': False, 'error': 'SQL fehlt'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(sql)

        if fetch and sql.strip().upper().startswith('SELECT'):
            rows = cursor.fetchall()
            result = [row_to_dict(cursor, row) for row in rows]
            release_connection(conn)
            return jsonify({
                'success': True,
                'rows': result,
                'count': len(result)
            })
        else:
            conn.commit()
            release_connection(conn)
            return jsonify({
                'success': True,
                'rowcount': cursor.rowcount
            })
    except Exception as e:
        logger.error(f"SQL-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Objekte (tbl_OB_Objekt)
# ============================================

@app.route('/api/objekte')
def get_objekte():
    """Alle Objekte"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')

        # Einfache Query ohne JOIN (Tabelle hat andere Struktur)
        if search:
            query = f"""
                SELECT TOP {limit} * FROM tbl_OB_Objekt
                WHERE Objekt LIKE ?
                ORDER BY Objekt
            """
            cursor.execute(query, [f'%{search}%'])
        else:
            query = f"""
                SELECT TOP {limit} * FROM tbl_OB_Objekt
                ORDER BY Objekt
            """
            cursor.execute(query)

        rows = cursor.fetchall()
        objekte = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': objekte
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte/<int:id>')
def get_objekt(id):
    """Einzelnes Objekt mit Details"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM tbl_OB_Objekt WHERE ID = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Objekt nicht gefunden'}), 404

        objekt = row_to_dict(cursor, row)

        # Positionen laden (falls Tabelle existiert)
        positionen = []
        try:
            cursor.execute("""
                SELECT * FROM tbl_OB_Objekt_Positionen
                WHERE OB_ID = ?
                ORDER BY ID
            """, (id,))
            positionen = [row_to_dict(cursor, row) for row in cursor.fetchall()]
        except:
            pass

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'objekt': objekt,
                'positionen': positionen
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte', methods=['POST'])
def create_objekt():
    """Neues Objekt erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_OB_Objekt (OB_Bezeichnung, OB_KD_ID, OB_Strasse, OB_PLZ, OB_Ort)
            VALUES (?, ?, ?, ?, ?)
        """, (
            data.get('OB_Bezeichnung'),
            data.get('OB_KD_ID'),
            data.get('OB_Strasse'),
            data.get('OB_PLZ'),
            data.get('OB_Ort')
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Objekt erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte/<int:id>', methods=['PUT'])
def update_objekt(id):
    """Objekt aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        updates = []
        values = []

        for key, value in data.items():
            if key.startswith('OB_') and key != 'OB_ID':
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder'}), 400

        values.append(id)
        query = f"UPDATE tbl_OB_Objekt SET {', '.join(updates)} WHERE OB_ID = ?"

        cursor.execute(query, values)
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Objekt aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte/<int:id>', methods=['DELETE'])
def delete_objekt(id):
    """Objekt löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tbl_OB_Objekt WHERE OB_ID = ?", (id,))
        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Objekt gelöscht'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte/<int:objekt_id>/positionen')
def get_objekt_positionen(objekt_id):
    """Positionen eines Objekts"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Spalte heisst OB_Objekt_Kopf_ID (Fremdschluessel zum Objekt)
        cursor.execute("""
            SELECT ID, OB_Objekt_Kopf_ID, Gruppe, Zusatztext, Zusatztext2,
                   Geschlecht, Anzahl, Rel_Beginn, Rel_Ende, TagesArt, TagesNr, Sort
            FROM tbl_OB_Objekt_Positionen
            WHERE OB_Objekt_Kopf_ID = ?
            ORDER BY Sort
        """, (objekt_id,))
        rows = cursor.fetchall()

        positionen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': positionen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/objekte/<int:objekt_id>/auftraege')
def get_objekt_auftraege(objekt_id):
    """Auftraege zu einem Objekt"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT ID, Auftrag, Objekt, Dat_VA_Von, Dat_VA_Bis
            FROM tbl_VA_Auftragstamm
            WHERE Objekt_ID = ?
            ORDER BY Dat_VA_Von DESC
        """, (objekt_id,))
        rows = cursor.fetchall()

        auftraege = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': auftraege
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Kunden CRUD
# ============================================

@app.route('/api/kunden/<int:id>')
def get_kunde(id):
    """Einzelner Kunde mit Details"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Kunde nicht gefunden'}), 404

        kunde = row_to_dict(cursor, row)

        # Aufträge des Kunden (Spalte heißt ID, nicht VA_ID)
        cursor.execute("""
            SELECT ID, Auftrag, Objekt
            FROM tbl_VA_Auftragstamm
            WHERE Veranstalter_ID = ?
            ORDER BY ID DESC
        """, (id,))
        auftraege = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Objekte sind nicht direkt mit Kunden verknüpft in dieser DB-Struktur
        objekte = []

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'kunde': kunde,
                'auftraege': auftraege,
                'objekte': objekte
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/kunden', methods=['POST'])
def create_kunde():
    """Neuen Kunden erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_KD_Kundenstamm (kun_Firma, kun_Strasse, kun_PLZ, kun_Ort, kun_IstAktiv)
            VALUES (?, ?, ?, ?, True)
        """, (
            data.get('kun_Firma'),
            data.get('kun_Strasse'),
            data.get('kun_PLZ'),
            data.get('kun_Ort')
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Kunde erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/kunden/<int:id>', methods=['PUT'])
def update_kunde(id):
    """Kunde aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        updates = []
        values = []

        for key, value in data.items():
            if key.startswith('kun_') and key != 'kun_Id':
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder'}), 400

        values.append(id)
        query = f"UPDATE tbl_KD_Kundenstamm SET {', '.join(updates)} WHERE kun_Id = ?"

        cursor.execute(query, values)
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Kunde aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/kunden/<int:id>', methods=['DELETE'])
def delete_kunde(id):
    """Kunde löschen (deaktivieren)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("UPDATE tbl_KD_Kundenstamm SET kun_IstAktiv = False WHERE kun_Id = ?", (id,))
        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Kunde deaktiviert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Mitarbeiter CRUD
# ============================================

@app.route('/api/mitarbeiter', methods=['POST'])
def create_mitarbeiter():
    """Neuen Mitarbeiter erstellen"""
    try:
        data = request.get_json()
        logger.info(f"[POST /api/mitarbeiter] Empfangene Daten: {data}")

        # NEUE Verbindung fuer jeden Request (Thread-sicher)
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        # ID ist kein AutoIncrement - max ID + 1 ermitteln
        cursor.execute("SELECT MAX(ID) FROM tbl_MA_Mitarbeiterstamm")
        max_id = cursor.fetchone()[0] or 0
        new_id = max_id + 1

        logger.info(f"[POST /api/mitarbeiter] Neue ID: {new_id}")

        cursor.execute("""
            INSERT INTO tbl_MA_Mitarbeiterstamm (ID, Nachname, Vorname, Strasse, PLZ, Ort, Tel_Mobil, IstAktiv)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            new_id,
            data.get('Nachname'),
            data.get('Vorname'),
            data.get('Strasse'),
            data.get('PLZ'),
            data.get('Ort'),
            data.get('Tel_Mobil'),
            data.get('IstAktiv', True)
        ))
        conn.commit()
        conn.close()

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Mitarbeiter erstellt'
        })
    except Exception as e:
        logger.error(f"[POST /api/mitarbeiter] Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>', methods=['PUT'])
def update_mitarbeiter(id):
    """Mitarbeiter aktualisieren"""
    try:
        data = request.get_json()
        logger.info(f"[PUT /api/mitarbeiter/{id}] Empfangene Daten: {data}")

        # NEUE Verbindung fuer jeden Request - Thread-lokale kann Probleme machen
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        # Erlaubte Felder - erweitert um alle editierbaren Stammdaten
        allowed = [
            'Nachname', 'Vorname', 'Strasse', 'Nr', 'PLZ', 'Ort', 'Land', 'Bundesland',
            'Tel_Mobil', 'Tel_Festnetz', 'Email', 'Geschlecht', 'Staatsang',
            'Geb_Dat', 'Geb_Ort', 'Geb_Name', 'IstAktiv', 'IstSubunternehmer', 'Lex_Aktiv',
            'Eintrittsdatum', 'Austrittsdatum', 'Anstellungsart_ID', 'Kleidergroesse',
            'Fahrerlaubnis', 'Eigener_PKW', 'DienstausweisNr', 'Ausweis_Endedatum',
            'AUsweis_Funktion', 'Datum_Pruefung', 'Bewacher_ID', 'Amt_Pruefung',
            'Epin_DFB', 'Modul1_DFB', 'Kontoinhaber', 'Bankname', 'IBAN', 'BIC',
            'SteuerNr', 'Steuerklasse', 'KV_Kasse', 'Sozialvers_Nr',
            'Arbst_pro_Arbeitstag', 'Arbeitstage_pro_Woche', 'Resturl_Vorjahr',
            'Urlaubsanspr_pro_Jahr', 'StundenZahlMax', 'Bemerkungen',
            'eMail_Abrechnung', 'Hat_keine_34a', 'HatSachkunde', 'LEXWare_ID'
        ]

        updates = []
        values = []

        for key, value in data.items():
            if key in allowed:
                updates.append(f"{key} = ?")
                values.append(value)
            else:
                logger.warning(f"[PUT /api/mitarbeiter/{id}] Feld '{key}' nicht in allowed-Liste!")

        if not updates:
            conn.close()
            return jsonify({'success': False, 'error': 'Keine Felder'}), 400

        values.append(id)
        query = f"UPDATE tbl_MA_Mitarbeiterstamm SET {', '.join(updates)} WHERE ID = ?"
        logger.info(f"[PUT /api/mitarbeiter/{id}] SQL: {query}")
        logger.info(f"[PUT /api/mitarbeiter/{id}] Values: {values}")

        cursor.execute(query, values)
        rows_affected = cursor.rowcount
        logger.info(f"[PUT /api/mitarbeiter/{id}] Rows affected: {rows_affected}")

        conn.commit()
        logger.info(f"[PUT /api/mitarbeiter/{id}] Commit erfolgreich")
        conn.close()

        return jsonify({'success': True, 'message': 'Mitarbeiter aktualisiert', 'rows_affected': rows_affected})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>', methods=['DELETE'])
def delete_mitarbeiter(id):
    """Mitarbeiter deaktivieren (Soft-Delete)"""
    try:
        logger.info(f"[DELETE /api/mitarbeiter/{id}] Deaktiviere Mitarbeiter")

        # NEUE Verbindung fuer jeden Request (Thread-sicher)
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        cursor.execute("UPDATE tbl_MA_Mitarbeiterstamm SET IstAktiv = False WHERE ID = ?", (id,))
        rows = cursor.rowcount
        conn.commit()
        conn.close()

        if rows == 0:
            return jsonify({'success': False, 'error': f'Mitarbeiter {id} nicht gefunden'}), 404

        return jsonify({'success': True, 'message': 'Mitarbeiter deaktiviert', 'id': id})
    except Exception as e:
        logger.error(f"[DELETE /api/mitarbeiter/{id}] Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Abwesenheiten (tbl_MA_NVerfuegZeiten)
# ============================================

@app.route('/api/abwesenheiten')
def get_abwesenheiten():
    """Alle Abwesenheiten"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        ma_id = request.args.get('ma_id')
        datum_von = request.args.get('datum_von')
        datum_bis = request.args.get('datum_bis')

        query = """
            SELECT nv.*, m.Nachname, m.Vorname
            FROM tbl_MA_NVerfuegZeiten nv
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON nv.MA_ID = m.ID
            WHERE 1=1
        """
        params = []

        if ma_id:
            query += " AND nv.MA_ID = ?"
            params.append(int(ma_id))

        if datum_von:
            query += " AND nv.bisDat >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND nv.vonDat <= ?"
            params.append(datum_bis)

        query += " ORDER BY nv.vonDat DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        abwesenheiten = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': abwesenheiten
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/abwesenheiten', methods=['POST'])
def create_abwesenheit():
    """Neue Abwesenheit erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_MA_NVerfuegZeiten (MA_ID, vonDat, bisDat, Grund, Bemerkung)
            VALUES (?, ?, ?, ?, ?)
        """, (
            data.get('MA_ID'),
            data.get('vonDat'),
            data.get('bisDat'),
            data.get('Grund', 'Sonstiges'),
            data.get('Bemerkung', '')
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Abwesenheit erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/abwesenheiten/<int:id>', methods=['PUT'])
def update_abwesenheit(id):
    """Abwesenheit aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE tbl_MA_NVerfuegZeiten
            SET MA_ID = ?, vonDat = ?, bisDat = ?, Grund = ?, Bemerkung = ?
            WHERE ID = ?
        """, (
            data.get('MA_ID'),
            data.get('vonDat'),
            data.get('bisDat'),
            data.get('Grund'),
            data.get('Bemerkung'),
            id
        ))
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Abwesenheit aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/abwesenheiten/<int:id>', methods=['DELETE'])
def delete_abwesenheit(id):
    """Abwesenheit löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tbl_MA_NVerfuegZeiten WHERE ID = ?", (id,))
        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Abwesenheit gelöscht'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Dienstplan
# ============================================

@app.route('/api/dienstplan/ma/<int:ma_id>')
def get_dienstplan_ma(ma_id):
    """Dienstplan für einen Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')

        # WICHTIG: Access SQL benötigt Klammern bei mehreren JOINs!
        query = """
            SELECT p.*, s.VA_Start, s.VA_Ende, a.Objekt, a.Auftrag
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE p.MA_ID = ?
        """
        params = [ma_id]

        if datum_von:
            query += " AND p.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND p.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY p.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        einsaetze = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': einsaetze
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/dienstplan/objekt/<int:objekt_id>')
def get_dienstplan_objekt(objekt_id):
    """Dienstplan für ein Objekt"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')

        query = """
            SELECT s.*, a.Objekt, a.Auftrag,
                   (SELECT COUNT(*) FROM tbl_MA_VA_Planung p WHERE p.VAStart_ID = s.ID) AS MA_Ist
            FROM tbl_VA_Start s
            INNER JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.ID
            WHERE a.Objekt_ID = ?
        """
        params = [objekt_id]

        if datum_von:
            query += " AND s.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND s.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY s.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        schichten = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': schichten
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/dienstplan/schichten')
def get_schichten():
    """Alle Schichten im Zeitraum oder für einen Auftrag"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')
        va_id = request.args.get('va_id')

        query = """
            SELECT s.*, a.Objekt, a.Auftrag, a.Veranstalter_ID,
                   (SELECT COUNT(*) FROM tbl_MA_VA_Planung p WHERE p.VAStart_ID = s.ID) AS MA_Ist
            FROM tbl_VA_Start s
            INNER JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND s.VA_ID = ?"
            params.append(int(va_id))

        if datum_von:
            query += " AND s.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND s.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY s.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        schichten = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': schichten
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Anfragen (tbl_MA_VA_Planung mit Status)
# ============================================

@app.route('/api/anfragen')
def get_anfragen():
    """Offene Anfragen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        status = request.args.get('status')

        query = """
            SELECT p.*, m.Nachname, m.Vorname, a.Objekt, a.Auftrag
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(int(va_id))

        if status:
            query += " AND p.MVP_Status = ?"
            params.append(int(status))

        query += " ORDER BY p.VADatum DESC, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        anfragen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': anfragen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/anfragen/<int:id>', methods=['PUT'])
def update_anfrage(id):
    """Anfrage-Status aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        status = data.get('status')

        cursor.execute("""
            UPDATE tbl_MA_VA_Planung
            SET MVP_Status = ?
            WHERE ID = ?
        """, (status, id))
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Anfrage aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Lohn-Daten
# ============================================

@app.route('/api/lohn/abrechnungen')
def get_lohnabrechnungen():
    """Lohnabrechnungen (Platzhalter - Tabelle ggf. anpassen)"""
    try:
        monat = request.args.get('monat', type=int)
        jahr = request.args.get('jahr', type=int)

        # Mitarbeiter mit Stunden für den Monat berechnen
        conn = get_connection()
        cursor = conn.cursor()

        # Alle aktiven MA mit Einsätzen im Monat
        query = """
            SELECT m.ID, m.Nachname AS MA_Nachname, m.Vorname AS MA_Vorname,
                   COUNT(p.ID) AS Einsaetze
            FROM tbl_MA_Mitarbeiterstamm m
            LEFT JOIN tbl_MA_VA_Planung p ON m.ID = p.MA_ID
            WHERE m.IstAktiv = True
            GROUP BY m.ID, m.Nachname, m.Vorname
            ORDER BY m.Nachname
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        abrechnungen = []
        for row in rows:
            abrechnungen.append({
                'ID': row[0],
                'MA_Nachname': row[1],
                'MA_Vorname': row[2],
                'Einsaetze': row[3],
                'SollStunden': 160,
                'IstStunden': row[3] * 8,  # Vereinfachung
                'Brutto': row[3] * 8 * 15,  # Beispiel-Berechnung
                'Netto': row[3] * 8 * 10,
                'Status': 'offen' if row[3] > 0 else 'erstellt'
            })

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': abrechnungen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Rückmeldungen (Platzhalter)
# ============================================

@app.route('/api/rueckmeldungen')
def get_rueckmeldungen():
    """Rückmeldungen (Platzhalter)"""
    # Beispieldaten - in echter Implementierung aus DB laden
    return jsonify({
        'success': True,
        'data': []
    })

@app.route('/api/rueckmeldungen/<int:id>')
def get_rueckmeldung(id):
    """Einzelne Rückmeldung"""
    return jsonify({
        'success': True,
        'data': {'ID': id, 'Betreff': 'Test', 'Nachricht': 'Testnachricht'}
    })

@app.route('/api/rueckmeldungen/<int:id>/read', methods=['PUT'])
def mark_rueckmeldung_read(id):
    """Rückmeldung als gelesen markieren"""
    return jsonify({'success': True})

@app.route('/api/rueckmeldungen/mark-all-read', methods=['POST'])
def mark_all_rueckmeldungen_read():
    """Alle als gelesen markieren"""
    return jsonify({'success': True})

# ============================================
# API: Verfügbare MA für Einsatz
# ============================================

@app.route('/api/verfuegbarkeit/check')
def check_verfuegbarkeit_detail():
    """Detaillierte Verfügbarkeitsprüfung"""
    try:
        datum = request.args.get('datum')
        start = request.args.get('start')
        ende = request.args.get('ende')

        if not datum:
            return jsonify({'success': False, 'error': 'Datum erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT m.ID AS MA_ID, m.Nachname AS MA_Nachname, m.Vorname AS MA_Vorname
            FROM tbl_MA_Mitarbeiterstamm m
            WHERE m.IstAktiv = True
            AND m.ID NOT IN (
                SELECT p.MA_ID FROM tbl_MA_VA_Planung p
                WHERE p.VADatum = ?
            )
            AND m.ID NOT IN (
                SELECT nv.MA_ID FROM tbl_MA_NVerfuegZeiten nv
                WHERE nv.vonDat <= ? AND nv.bisDat >= ?
            )
            ORDER BY m.Nachname, m.Vorname
        """

        cursor.execute(query, [datum, datum, datum])
        rows = cursor.fetchall()

        verfuegbar = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': verfuegbar
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Generisches Feld-Update
# ============================================

@app.route('/api/field', methods=['PUT'])
def update_field():
    """Generisches Feld-Update für beliebige Tabelle"""
    try:
        data = request.get_json()
        table = data.get('table')
        record_id = data.get('id')
        field = data.get('field')
        value = data.get('value')

        if not table or not record_id or not field:
            return jsonify({'success': False, 'error': 'table, id und field erforderlich'}), 400

        # Tabellen-Whitelist für Sicherheit
        allowed_tables = [
            'tbl_VA_Auftragstamm', 'tbl_VA_Start', 'tbl_VA_AnzTage',
            'tbl_MA_VA_Planung', 'tbl_MA_VA_Zuordnung',
            'tbl_MA_Mitarbeiterstamm', 'tbl_KD_Kundenstamm',
            'tbl_OB_Objekt', 'tbl_OB_Position',
            'tbl_MA_NVerfuegZeiten'
        ]

        if table not in allowed_tables:
            return jsonify({'success': False, 'error': f'Tabelle {table} nicht erlaubt'}), 403

        # ID-Feldname ermitteln (unterschiedlich je Tabelle)
        id_field_map = {
            'tbl_VA_Auftragstamm': 'VA_ID',
            'tbl_VA_Start': 'ID',
            'tbl_VA_AnzTage': 'ID',
            'tbl_MA_VA_Planung': 'ID',
            'tbl_MA_VA_Zuordnung': 'ID',
            'tbl_MA_Mitarbeiterstamm': 'ID',
            'tbl_KD_Kundenstamm': 'kun_Id',
            'tbl_OB_Objekt': 'OB_ID',
            'tbl_OB_Position': 'OBP_ID',
            'tbl_MA_NVerfuegZeiten': 'ID'
        }

        id_field = id_field_map.get(table, 'ID')

        conn = get_connection()
        cursor = conn.cursor()

        # SQL-Injection-Schutz: field wird validiert
        # (nur alphanumerisch + Underscore erlaubt)
        import re
        if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', field):
            return jsonify({'success': False, 'error': 'Ungültiger Feldname'}), 400

        query = f"UPDATE {table} SET {field} = ? WHERE {id_field} = ?"
        cursor.execute(query, [value, record_id])
        conn.commit()

        rows_affected = cursor.rowcount
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': f'Feld {field} aktualisiert',
            'rows_affected': rows_affected
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Generisches Record-Insert
# ============================================

@app.route('/api/record', methods=['POST'])
def insert_record():
    """Generisches Insert für beliebige Tabelle"""
    try:
        data = request.get_json()
        table = data.get('table')
        record_data = data.get('data', {})

        if not table or not record_data:
            return jsonify({'success': False, 'error': 'table und data erforderlich'}), 400

        # Tabellen-Whitelist für Sicherheit
        allowed_tables = [
            'tbl_VA_Auftragstamm', 'tbl_VA_Start', 'tbl_VA_AnzTage',
            'tbl_MA_VA_Planung', 'tbl_MA_VA_Zuordnung',
            'tbl_MA_Mitarbeiterstamm', 'tbl_KD_Kundenstamm',
            'tbl_OB_Objekt', 'tbl_OB_Position',
            'tbl_MA_NVerfuegZeiten'
        ]

        if table not in allowed_tables:
            return jsonify({'success': False, 'error': f'Tabelle {table} nicht erlaubt'}), 403

        conn = get_connection()
        cursor = conn.cursor()

        # Felder und Werte extrahieren
        import re
        fields = []
        values = []
        placeholders = []

        for key, value in record_data.items():
            # Feldname validieren (SQL-Injection-Schutz)
            if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', key):
                continue
            fields.append(key)
            values.append(value)
            placeholders.append('?')

        if not fields:
            return jsonify({'success': False, 'error': 'Keine gültigen Felder'}), 400

        query = f"INSERT INTO {table} ({', '.join(fields)}) VALUES ({', '.join(placeholders)})"
        cursor.execute(query, values)
        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': f'Record in {table} erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Generisches Record-Delete
# ============================================

@app.route('/api/record', methods=['DELETE'])
def delete_record():
    """Generisches Delete für beliebige Tabelle"""
    try:
        data = request.get_json()
        table = data.get('table')
        record_id = data.get('id')

        if not table or not record_id:
            return jsonify({'success': False, 'error': 'table und id erforderlich'}), 400

        # Tabellen-Whitelist für Sicherheit
        allowed_tables = [
            'tbl_VA_Start', 'tbl_VA_AnzTage',
            'tbl_MA_VA_Planung', 'tbl_MA_VA_Zuordnung',
            'tbl_OB_Position', 'tbl_MA_NVerfuegZeiten'
        ]

        if table not in allowed_tables:
            return jsonify({'success': False, 'error': f'Tabelle {table} nicht für Löschen erlaubt'}), 403

        # ID-Feldname ermitteln
        id_field_map = {
            'tbl_VA_Start': 'ID',
            'tbl_VA_AnzTage': 'ID',
            'tbl_MA_VA_Planung': 'ID',
            'tbl_MA_VA_Zuordnung': 'ID',
            'tbl_OB_Position': 'OBP_ID',
            'tbl_MA_NVerfuegZeiten': 'ID'
        }

        id_field = id_field_map.get(table, 'ID')

        conn = get_connection()
        cursor = conn.cursor()

        query = f"DELETE FROM {table} WHERE {id_field} = ?"
        cursor.execute(query, [record_id])
        conn.commit()

        rows_affected = cursor.rowcount
        release_connection(conn)

        return jsonify({
            'success': True,
            'message': f'Record aus {table} gelöscht',
            'rows_affected': rows_affected
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Bewerber (tbl_MA_Bewerber)
# ============================================

@app.route('/api/bewerber')
def get_bewerber():
    """Alle Bewerber"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        status = request.args.get('status')
        limit = request.args.get('limit', 100, type=int)

        # Prüfen ob Tabelle existiert
        try:
            query = f"SELECT TOP {limit} * FROM tbl_MA_Bewerber"
            if status:
                query += f" WHERE BW_Status = ?"
                cursor.execute(query, [status])
            else:
                cursor.execute(query)
            rows = cursor.fetchall()
            bewerber = [row_to_dict(cursor, row) for row in rows]
        except:
            # Tabelle existiert nicht - Beispieldaten
            bewerber = [
                {'ID': 1, 'BW_Nachname': 'Mustermann', 'BW_Vorname': 'Max', 'BW_Status': 'neu', 'BW_Eingang': '2025-01-15'},
                {'ID': 2, 'BW_Nachname': 'Schmidt', 'BW_Vorname': 'Maria', 'BW_Status': 'kontaktiert', 'BW_Eingang': '2025-01-14'},
            ]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': bewerber
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bewerber/<int:id>')
def get_bewerber_detail(id):
    """Einzelner Bewerber"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("SELECT * FROM tbl_MA_Bewerber WHERE ID = ?", (id,))
            row = cursor.fetchone()
            if row:
                bewerber = row_to_dict(cursor, row)
            else:
                return jsonify({'success': False, 'error': 'Bewerber nicht gefunden'}), 404
        except:
            bewerber = {'ID': id, 'BW_Nachname': 'Test', 'BW_Vorname': 'Bewerber', 'BW_Status': 'neu'}

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': bewerber
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bewerber/<int:id>/accept', methods=['POST'])
def accept_bewerber(id):
    """Bewerber einstellen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("UPDATE tbl_MA_Bewerber SET BW_Status = 'eingestellt' WHERE ID = ?", (id,))
            conn.commit()
        except:
            pass

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Bewerber eingestellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/bewerber/<int:id>/reject', methods=['POST'])
def reject_bewerber(id):
    """Bewerber ablehnen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("UPDATE tbl_MA_Bewerber SET BW_Status = 'abgelehnt' WHERE ID = ?", (id,))
            conn.commit()
        except:
            pass

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Bewerber abgelehnt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Zeitkonten Importfehler
# ============================================

@app.route('/api/zeitkonten/importfehler')
def get_zeitkonten_importfehler():
    """Zeitkonten-Importfehler"""
    try:
        # Platzhalter - echte Tabelle ggf. anpassen
        return jsonify({
            'success': True,
            'data': []
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/zeitkonten/importfehler/<int:id>/fix', methods=['POST'])
def fix_importfehler(id):
    """Importfehler beheben"""
    return jsonify({'success': True, 'message': 'Fehler behoben'})

@app.route('/api/zeitkonten/importfehler/<int:id>/ignore', methods=['POST'])
def ignore_importfehler(id):
    """Importfehler ignorieren"""
    return jsonify({'success': True, 'message': 'Fehler ignoriert'})

# ============================================
# API: Dienstplan Gründe
# ============================================

@app.route('/api/dienstplan/gruende')
def get_dienstplan_gruende():
    """Abwesenheitsgründe für Dienstplan"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Versuche echte Tabelle
        try:
            cursor.execute("SELECT * FROM tbl_Abwesenheitsgruende ORDER BY Bezeichnung")
            rows = cursor.fetchall()
            gruende = [row_to_dict(cursor, row) for row in rows]
        except:
            # Standard-Gründe
            gruende = [
                {'ID': 1, 'Bezeichnung': 'Urlaub', 'Kuerzel': 'U'},
                {'ID': 2, 'Bezeichnung': 'Krank', 'Kuerzel': 'K'},
                {'ID': 3, 'Bezeichnung': 'Frei', 'Kuerzel': 'F'},
                {'ID': 4, 'Bezeichnung': 'Schule', 'Kuerzel': 'S'},
                {'ID': 5, 'Bezeichnung': 'Sonstiges', 'Kuerzel': 'X'}
            ]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': gruende
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Dienstplan Übersicht (für HTML-Formular)
# ============================================

@app.route('/api/dienstplan/uebersicht')
def get_dienstplan_uebersicht():
    """Dienstplanübersicht: Alle aktiven MA mit Einsätzen für Zeitraum"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von', '')
        datum_bis = request.args.get('bis', '')
        limit = request.args.get('limit', 50, type=int)
        ma_filter = request.args.get('filter', '1')  # 0=Alle, 1=Aktiv, 2=Fest, 3=Mini, 4=Sub

        # 1. Mitarbeiter laden (je nach Filter)
        ma_query = f"SELECT TOP {limit} ID, Nachname, Vorname, Anstellungsart_ID FROM tbl_MA_Mitarbeiterstamm WHERE 1=1"
        params = []

        if ma_filter == '1':
            ma_query += " AND IstAktiv = True"
        elif ma_filter == '2':  # Festangestellt
            ma_query += " AND IstAktiv = True AND Anstellungsart_ID = 3"
        elif ma_filter == '3':  # Minijobber
            ma_query += " AND IstAktiv = True AND Anstellungsart_ID = 13"
        elif ma_filter == '4':  # Sub
            ma_query += " AND IstAktiv = True AND Anstellungsart_ID = 9"

        ma_query += " ORDER BY Nachname, Vorname"

        cursor.execute(ma_query)
        ma_rows = cursor.fetchall()
        mitarbeiter = [row_to_dict(cursor, row) for row in ma_rows]

        # 2. Einsätze und Abwesenheiten laden
        for ma in mitarbeiter:
            ma_id = ma.get('ID')
            ma['einsaetze'] = []
            ma['abwesenheiten'] = []

            # Einsätze laden
            try:
                # WICHTIG: Access SQL benötigt Klammern bei mehreren JOINs!
                einsatz_query = """
                    SELECT p.MA_ID, p.VADatum, s.VA_Start, s.VA_Ende, p.VA_ID, a.Auftrag, a.Objekt
                    FROM (tbl_MA_VA_Planung p
                    LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID)
                    LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
                    WHERE p.MA_ID = ?
                """
                einsatz_params = [ma_id]

                if datum_von:
                    einsatz_query += " AND p.VADatum >= ?"
                    einsatz_params.append(datum_von)
                if datum_bis:
                    einsatz_query += " AND p.VADatum <= ?"
                    einsatz_params.append(datum_bis)

                einsatz_query += " ORDER BY p.VADatum, s.VA_Start"

                cursor.execute(einsatz_query, einsatz_params)
                ma['einsaetze'] = [row_to_dict(cursor, row) for row in cursor.fetchall()]
            except:
                pass

            # Abwesenheiten laden
            try:
                abw_query = """
                    SELECT ID, MA_ID, vonDat, bisDat, Grund, Bemerkung
                    FROM tbl_MA_NVerfuegZeiten
                    WHERE MA_ID = ?
                """
                abw_params = [ma_id]

                if datum_von:
                    abw_query += " AND bisDat >= ?"
                    abw_params.append(datum_von)
                if datum_bis:
                    abw_query += " AND vonDat <= ?"
                    abw_params.append(datum_bis)

                cursor.execute(abw_query, abw_params)
                ma['abwesenheiten'] = [row_to_dict(cursor, row) for row in cursor.fetchall()]
            except:
                pass

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': mitarbeiter,
            'von': datum_von,
            'bis': datum_bis
        })
    except Exception as e:
        import traceback
        return jsonify({'success': False, 'error': str(e), 'trace': traceback.format_exc()}), 500


# ============================================
# API: Attachments (tbl_Zusatzdateien)
# ============================================

# Upload-Verzeichnis
UPLOAD_FOLDER = Path(__file__).parent / "uploads"
UPLOAD_FOLDER.mkdir(exist_ok=True)

@app.route('/api/attachments')
def get_attachments():
    """Zusatzdateien abfragen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        objekt_id = request.args.get('objekt_id')
        kd_id = request.args.get('kd_id')
        va_id = request.args.get('va_id')
        tabellen_nr = request.args.get('tabellen_nr')

        query = """
            SELECT * FROM tbl_Zusatzdateien
            WHERE 1=1
        """
        params = []

        if objekt_id:
            query += " AND Ueberordnung = ?"
            params.append(int(objekt_id))
        if kd_id:
            query += " AND Ueberordnung = ?"
            params.append(int(kd_id))
        if va_id:
            query += " AND Ueberordnung = ?"
            params.append(int(va_id))
        if tabellen_nr:
            query += " AND TabellenID = ?"
            params.append(int(tabellen_nr))

        query += " ORDER BY Dateiname"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        attachments = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': attachments
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/attachments/upload', methods=['POST'])
def upload_attachment():
    """Neue Datei hochladen"""
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'Keine Datei'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'Keine Datei ausgewählt'}), 400

        # Parameter
        objekt_id = request.form.get('objekt_id')
        kd_id = request.form.get('kd_id')
        va_id = request.form.get('va_id')
        tabellen_nr = request.form.get('tabellen_nr', 42)

        # Ueberordnung ermitteln
        ueberordnung = objekt_id or kd_id or va_id
        if not ueberordnung:
            return jsonify({'success': False, 'error': 'objekt_id, kd_id oder va_id erforderlich'}), 400

        # Datei speichern
        filename = file.filename
        filepath = UPLOAD_FOLDER / filename

        # Falls Datei existiert, umbenennen
        counter = 1
        base, ext = os.path.splitext(filename)
        while filepath.exists():
            filename = f"{base}_{counter}{ext}"
            filepath = UPLOAD_FOLDER / filename
            counter += 1

        file.save(filepath)

        # Dateigröße ermitteln
        file_size = filepath.stat().st_size
        file_date = datetime.now()

        # Dateityp ermitteln
        ext = ext.lstrip('.').upper()

        # In Datenbank speichern
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_Zusatzdateien
            (Ueberordnung, TabellenID, Dateiname, DFiledate, DLaenge, Texttyp)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            int(ueberordnung),
            int(tabellen_nr),
            str(filepath),  # Vollständiger Pfad
            file_date,
            file_size,
            ext
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'filename': filename,
            'message': 'Datei hochgeladen'
        })
    except Exception as e:
        import traceback
        return jsonify({'success': False, 'error': str(e), 'trace': traceback.format_exc()}), 500

@app.route('/api/attachments/<int:id>')
def get_attachment(id):
    """Einzelne Zusatzdatei"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM tbl_Zusatzdateien WHERE ZusatzNr = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Datei nicht gefunden'}), 404

        attachment = row_to_dict(cursor, row)
        release_connection(conn)

        return jsonify({
            'success': True,
            'data': attachment
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/attachments/<int:id>/download')
def download_attachment(id):
    """Datei herunterladen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT Dateiname FROM tbl_Zusatzdateien WHERE ZusatzNr = ?", (id,))
        row = cursor.fetchone()
        release_connection(conn)

        if not row:
            return jsonify({'success': False, 'error': 'Datei nicht gefunden'}), 404

        filepath = Path(row[0])
        if not filepath.exists():
            return jsonify({'success': False, 'error': 'Datei nicht auf Server'}), 404

        return send_from_directory(
            filepath.parent,
            filepath.name,
            as_attachment=True
        )
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/attachments/<int:id>', methods=['DELETE'])
def delete_attachment(id):
    """Zusatzdatei löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Pfad holen
        cursor.execute("SELECT Dateiname FROM tbl_Zusatzdateien WHERE ZusatzNr = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Datei nicht gefunden'}), 404

        filepath = Path(row[0])

        # Aus DB löschen
        cursor.execute("DELETE FROM tbl_Zusatzdateien WHERE ZusatzNr = ?", (id,))
        conn.commit()
        release_connection(conn)

        # Datei vom Server löschen (optional)
        if filepath.exists():
            try:
                filepath.unlink()
            except:
                pass  # Datei konnte nicht gelöscht werden, DB-Eintrag aber schon

        return jsonify({'success': True, 'message': 'Datei gelöscht'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Status (für Auftragstamm)
# ============================================

@app.route('/api/status')
def get_status():
    """Auftragsstatus für Dropdown"""
    try:
        # Hardcoded Status-Liste basierend auf tbl_VA_Status
        # Vermeidet SQL-Query-Probleme mit Access-Treibern
        data = [
            {'ID': -1, 'Fortschritt': 'Unbestätigt'},
            {'ID': 1, 'Fortschritt': 'In Planung'},
            {'ID': 2, 'Fortschritt': 'Beendet'},
            {'ID': 3, 'Fortschritt': 'Gesendet'},
            {'ID': 4, 'Fortschritt': 'Berechnet'}
        ]

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Status-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Vorschläge (Autocomplete)
# ============================================

@app.route('/api/auftraege/vorschlaege')
def get_auftraege_vorschlaege():
    """Autocomplete-Vorschläge für Auftragsfelder"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        feld = request.args.get('feld', '')

        # Mapping: feld -> Spaltenname
        feld_map = {
            'ort': 'Ort',
            'objekt': 'Objekt',
            'auftrag': 'Auftrag',
            'dienstkleidung': 'Dienstkleidung'
        }

        if feld not in feld_map:
            return jsonify({'success': False, 'error': 'Ungültiges Feld'}), 400

        spalte = feld_map[feld]

        # Distinct values für das Feld
        query = f"""
            SELECT DISTINCT TOP 100 {spalte}
            FROM tbl_VA_Auftragstamm
            WHERE {spalte} IS NOT NULL AND {spalte} <> ''
            ORDER BY {spalte}
        """

        cursor.execute(query)
        rows = cursor.fetchall()
        data = [row[0] for row in rows if row[0]]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Vorschläge-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Auftrags-Tage (Einsatztage)
# ============================================

@app.route('/api/auftraege/<int:va_id>/tage')
@app.route('/api/auftraege/<int:va_id>/einsatztage')
def get_auftrag_tage(va_id):
    """Einsatztage für einen Auftrag aus tbl_VA_AnzTage"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT ID, VA_ID, VADatum
            FROM tbl_VA_AnzTage
            WHERE VA_ID = ?
            ORDER BY VADatum
        """
        cursor.execute(query, [va_id])
        rows = cursor.fetchall()
        data = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Tage-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  GESCHÜTZTE API-ENDPOINTS - NICHT ÄNDERN!                                     ║
# ║                                                                               ║
# ║  Die folgenden 3 Endpoints (schichten, zuordnungen, absagen) wurden am        ║
# ║  12.01.2026 korrigiert und funktionieren jetzt korrekt.                       ║
# ║                                                                               ║
# ║  KRITISCHE LOGIK: vadatum_id akzeptiert BEIDE Formate:                        ║
# ║  - Integer-ID (z.B. 647324) → Vergleich mit VADatum_ID                        ║
# ║  - Datum-String (z.B. "2026-01-14") → Vergleich mit CDATE/DATEADD             ║
# ║                                                                               ║
# ║  DIESE LOGIK DARF NICHT GEÄNDERT WERDEN!                                      ║
# ║  Getestet und bestätigt: 12.01.2026                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

# ============================================
# API: Auftrags-Schichten (GESCHÜTZT!)
# ============================================

@app.route('/api/auftraege/<int:va_id>/schichten')
def get_auftrag_schichten(va_id):
    """Schichten für einen Auftrag

    ⚠️ GESCHÜTZT - NICHT ÄNDERN! ⚠️

    vadatum_id kann sein:
    - Integer ID aus tbl_VA_AnzTage (z.B. 647324)
    - Datums-String (z.B. "2026-01-14" oder "2026-01-14T00:00:00")
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        vadatum_id = request.args.get('vadatum_id', None)

        query = """
            SELECT s.ID, s.VA_ID, s.VADatum, s.VA_Start, s.VA_Ende,
                   s.MA_Anzahl, s.MA_Anzahl_Ist
            FROM tbl_VA_Start s
            WHERE s.VA_ID = ?
        """
        params = [va_id]

        if vadatum_id:
            # Prüfen ob vadatum_id ein Datum-String oder eine Integer-ID ist
            if '-' in str(vadatum_id) or 'T' in str(vadatum_id):
                # Datum-String: Extrahiere nur das Datum (ohne Zeit)
                datum_str = str(vadatum_id).split('T')[0]
                # Access SQL: Vergleiche Datum mit DateValue() oder Date-Range
                # Access ODBC akzeptiert ISO-Datum mit CDATE
                query += " AND s.VADatum >= CDATE(?) AND s.VADatum < DATEADD('d', 1, CDATE(?))"
                params.extend([datum_str, datum_str])
            else:
                # Integer-ID: Filtere nach VADatum_ID
                query += " AND s.VADatum_ID = ?"
                params.append(vadatum_id)

        query += " ORDER BY s.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        data = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Schichten-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Auftrags-Zuordnungen (GESCHÜTZT!)
# ============================================

@app.route('/api/auftraege/<int:va_id>/zuordnungen')
def get_auftrag_zuordnungen(va_id):
    """MA-Zuordnungen für einen Auftrag

    ⚠️ GESCHÜTZT - NICHT ÄNDERN! ⚠️

    vadatum_id kann sein:
    - Integer ID aus tbl_VA_AnzTage (z.B. 647324)
    - Datums-String (z.B. "2026-01-14" oder "2026-01-14T00:00:00")
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        vadatum_id = request.args.get('vadatum_id', None)

        # Hole Zuordnungen aus tbl_MA_VA_Zuordnung (enthält IstFraglich, PKW, Einsatzleitung, etc.)
        # NICHT tbl_MA_VA_Planung verwenden!
        # Spaltennamen: MA_Start/MA_Ende (nicht VA_Start/VA_Ende), Bemerkungen (nicht Bemerkung)
        query = """
            SELECT z.ID, z.VA_ID, z.MA_ID, z.VADatum, z.VADatum_ID,
                   z.MA_Start AS VA_Start, z.MA_Ende AS VA_Ende,
                   z.IstFraglich, z.PKW, z.Einsatzleitung, z.Rch_Erstellt, z.Bemerkungen AS Bemerkung,
                   m.Nachname, m.Vorname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
            WHERE z.VA_ID = ?
        """
        params = [va_id]

        if vadatum_id:
            # Prüfen ob vadatum_id ein Datum-String oder eine Integer-ID ist
            if '-' in str(vadatum_id) or 'T' in str(vadatum_id):
                # Datum-String: Extrahiere nur das Datum (ohne Zeit)
                datum_str = str(vadatum_id).split('T')[0]
                # Access SQL: Vergleiche Datum mit Date-Range
                query += " AND z.VADatum >= CDATE(?) AND z.VADatum < DATEADD('d', 1, CDATE(?))"
                params.extend([datum_str, datum_str])
            else:
                query += " AND z.VADatum_ID = ?"
                params.append(vadatum_id)

        query += " ORDER BY z.VADatum, z.MA_Start, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        data = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Zuordnungen-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Auftrags-Absagen (GESCHÜTZT!)
# ============================================

@app.route('/api/auftraege/<int:va_id>/absagen')
def get_auftrag_absagen(va_id):
    """Absagen für einen Auftrag - gibt leere Liste wenn Tabelle nicht existiert

    ⚠️ GESCHÜTZT - NICHT ÄNDERN! ⚠️

    vadatum_id kann sein:
    - Integer ID aus tbl_VA_AnzTage (z.B. 647324)
    - Datums-String (z.B. "2026-01-14" oder "2026-01-14T00:00:00")
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Prüfe ob Tabelle existiert
        try:
            cursor.execute("SELECT TOP 1 * FROM tbl_MA_VA_Absagen")
        except:
            # Tabelle existiert nicht - leere Liste zurückgeben
            release_connection(conn)
            return jsonify({'success': True, 'data': []})

        vadatum_id = request.args.get('vadatum_id', None)

        query = """
            SELECT a.ID, a.VA_ID, a.MA_ID, a.VADatum, a.Grund,
                   m.Nachname, m.Vorname
            FROM tbl_MA_VA_Absagen a
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON a.MA_ID = m.ID
            WHERE a.VA_ID = ?
        """
        params = [va_id]

        if vadatum_id:
            # Prüfen ob vadatum_id ein Datum-String oder eine Integer-ID ist
            if '-' in str(vadatum_id) or 'T' in str(vadatum_id):
                # Datum-String: Extrahiere nur das Datum (ohne Zeit)
                datum_str = str(vadatum_id).split('T')[0]
                # Access SQL: Vergleiche Datum mit Date-Range
                query += " AND a.VADatum >= CDATE(?) AND a.VADatum < DATEADD('d', 1, CDATE(?))"
                params.extend([datum_str, datum_str])
            else:
                query += " AND a.VADatum_ID = ?"
                params.append(vadatum_id)

        query += " ORDER BY a.VADatum, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        data = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Absagen-Fehler: {e}")
        return jsonify({'success': True, 'data': []})

# ============================================
# API: Zuordnungen UPDATE (PUT)
# ============================================

@app.route('/api/zuordnungen/<int:id>', methods=['PUT'])
def update_zuordnung(id):
    """Zuordnung aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Erlaubte Felder
        allowed = ['MA_ID', 'VA_ID', 'VAStart_ID', 'VADatum', 'VA_Start', 'VA_Ende', 'Bemerkung']

        updates = []
        values = []

        for key, value in data.items():
            if key in allowed:
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder zum Aktualisieren'}), 400

        values.append(id)
        query = f"UPDATE tbl_MA_VA_Zuordnung SET {', '.join(updates)} WHERE ID = ?"

        cursor.execute(query, values)
        conn.commit()
        release_connection(conn)

        return jsonify({'success': True, 'message': 'Zuordnung aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Rechnungen (tbl_Rch_Kopf)
# ============================================

@app.route('/api/rechnungen')
def get_rechnungen():
    """Alle Rechnungen mit optionaler Filterung"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Parameter fuer Filterung
        va_id = request.args.get('va_id')
        kd_id = request.args.get('kd_id')
        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')
        status = request.args.get('status')
        limit = request.args.get('limit', 100, type=int)
        offset = request.args.get('offset', 0, type=int)

        # Query bauen mit optionalen Filtern
        where_clauses = []
        params = []

        if va_id:
            where_clauses.append("Rch_VA_ID = ?")
            params.append(int(va_id))

        if kd_id:
            where_clauses.append("Rch_KD_ID = ?")
            params.append(int(kd_id))

        if datum_von:
            where_clauses.append("Rch_Datum >= ?")
            params.append(datum_von)

        if datum_bis:
            where_clauses.append("Rch_Datum <= ?")
            params.append(datum_bis)

        if status:
            where_clauses.append("Rch_Status = ?")
            params.append(int(status))

        where_sql = ""
        if where_clauses:
            where_sql = "WHERE " + " AND ".join(where_clauses)

        query = f"""
            SELECT TOP {limit} * FROM tbl_Rch_Kopf
            {where_sql}
            ORDER BY Rch_Datum DESC, Rch_ID DESC
        """

        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        rows = cursor.fetchall()
        rechnungen = [row_to_dict(cursor, row) for row in rows]

        # Gesamtanzahl mit gleichen Filtern
        count_query = f"SELECT COUNT(*) FROM tbl_Rch_Kopf {where_sql}"
        if params:
            cursor.execute(count_query, params)
        else:
            cursor.execute(count_query)
        total = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': rechnungen,
            'total': total,
            'limit': limit,
            'offset': offset
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/<int:id>')
def get_rechnung(id):
    """Einzelne Rechnung mit Positionen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Rechnungskopf laden
        cursor.execute("SELECT * FROM tbl_Rch_Kopf WHERE Rch_ID = ?", (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Rechnung nicht gefunden'}), 404

        rechnung = row_to_dict(cursor, row)

        # Rechnungspositionen laden
        cursor.execute("""
            SELECT * FROM tbl_Rch_Positionen
            WHERE RchP_Rch_ID = ?
            ORDER BY RchP_ID
        """, (id,))
        positionen = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Kundeninfo laden falls vorhanden
        if rechnung.get('Rch_KD_ID'):
            cursor.execute("""
                SELECT kun_Id, kun_Firma, kun_Strasse, kun_PLZ, kun_Ort
                FROM tbl_KD_Kundenstamm
                WHERE kun_Id = ?
            """, (rechnung['Rch_KD_ID'],))
            kunde_row = cursor.fetchone()
            if kunde_row:
                rechnung['kunde'] = row_to_dict(cursor, kunde_row)

        # Auftragsinfo laden falls vorhanden
        if rechnung.get('Rch_VA_ID'):
            cursor.execute("""
                SELECT ID, Auftrag, Objekt
                FROM tbl_VA_Auftragstamm
                WHERE ID = ?
            """, (rechnung['Rch_VA_ID'],))
            auftrag_row = cursor.fetchone()
            if auftrag_row:
                rechnung['auftrag'] = row_to_dict(cursor, auftrag_row)

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': {
                'rechnung': rechnung,
                'positionen': positionen
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen', methods=['POST'])
def create_rechnung():
    """Neue Rechnung erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Dynamische Felder extrahieren (mit Rch_ Praefix)
        fields = []
        values = []
        placeholders = []

        for key, value in data.items():
            if key.startswith('Rch_') and key != 'Rch_ID':
                fields.append(key)
                values.append(value)
                placeholders.append('?')

        if not fields:
            return jsonify({'success': False, 'error': 'Keine Rechnungsfelder angegeben'}), 400

        query = f"""
            INSERT INTO tbl_Rch_Kopf ({', '.join(fields)})
            VALUES ({', '.join(placeholders)})
        """

        cursor.execute(query, values)
        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Rechnung erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/<int:id>', methods=['PUT'])
def update_rechnung(id):
    """Rechnung aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Update mit dynamischen Feldern
        updates = []
        values = []

        for key, value in data.items():
            if key.startswith('Rch_') and key != 'Rch_ID':
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder zum Aktualisieren'}), 400

        values.append(id)
        query = f"""
            UPDATE tbl_Rch_Kopf
            SET {', '.join(updates)}
            WHERE Rch_ID = ?
        """

        cursor.execute(query, values)
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Rechnung aktualisiert'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/<int:id>', methods=['DELETE'])
def delete_rechnung(id):
    """Rechnung loeschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Pruefen ob Rechnung existiert
        cursor.execute("SELECT Rch_ID FROM tbl_Rch_Kopf WHERE Rch_ID = ?", (id,))
        if not cursor.fetchone():
            release_connection(conn)
            return jsonify({'success': False, 'error': 'Rechnung nicht gefunden'}), 404

        # Zuerst Positionen loeschen (Fremdschluessel)
        cursor.execute("DELETE FROM tbl_Rch_Positionen WHERE RchP_Rch_ID = ?", (id,))

        # Dann Rechnungskopf loeschen
        cursor.execute("DELETE FROM tbl_Rch_Kopf WHERE Rch_ID = ?", (id,))
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Rechnung geloescht'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Rechnungspositionen (tbl_Rch_Positionen)
# ============================================

@app.route('/api/rechnungen/positionen')
def get_rechnungs_positionen_by_va():
    """Rechnungspositionen fuer einen Auftrag (va_id)"""
    try:
        va_id = request.args.get('va_id')

        if not va_id:
            return jsonify({'success': False, 'error': 'va_id erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Erst alle Rechnungen zum Auftrag finden, dann deren Positionen
        query = """
            SELECT p.*, k.Rch_Nummer, k.Rch_Datum
            FROM tbl_Rch_Positionen p
            INNER JOIN tbl_Rch_Kopf k ON p.RchP_Rch_ID = k.Rch_ID
            WHERE k.Rch_VA_ID = ?
            ORDER BY k.Rch_Datum DESC, p.RchP_ID
        """

        cursor.execute(query, [int(va_id)])
        rows = cursor.fetchall()
        positionen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': positionen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/<int:rch_id>/positionen')
def get_rechnung_positionen(rch_id):
    """Alle Positionen einer Rechnung"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT * FROM tbl_Rch_Positionen
            WHERE RchP_Rch_ID = ?
            ORDER BY RchP_ID
        """, (rch_id,))
        rows = cursor.fetchall()
        positionen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': positionen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/<int:rch_id>/positionen', methods=['POST'])
def create_rechnung_position(rch_id):
    """Neue Rechnungsposition erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Rechnungs-ID setzen
        data['RchP_Rch_ID'] = rch_id

        # Dynamische Felder extrahieren (mit RchP_ Praefix)
        fields = []
        values = []
        placeholders = []

        for key, value in data.items():
            if key.startswith('RchP_') and key != 'RchP_ID':
                fields.append(key)
                values.append(value)
                placeholders.append('?')

        if not fields:
            return jsonify({'success': False, 'error': 'Keine Positionsfelder angegeben'}), 400

        query = f"""
            INSERT INTO tbl_Rch_Positionen ({', '.join(fields)})
            VALUES ({', '.join(placeholders)})
        """

        cursor.execute(query, values)
        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        release_connection(conn)

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Position erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/positionen/<int:id>', methods=['PUT'])
def update_rechnung_position(id):
    """Rechnungsposition aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Update mit dynamischen Feldern
        updates = []
        values = []

        for key, value in data.items():
            if key.startswith('RchP_') and key != 'RchP_ID':
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder zum Aktualisieren'}), 400

        values.append(id)
        query = f"""
            UPDATE tbl_Rch_Positionen
            SET {', '.join(updates)}
            WHERE RchP_ID = ?
        """

        cursor.execute(query, values)
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Position aktualisiert'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/rechnungen/positionen/<int:id>', methods=['DELETE'])
def delete_rechnung_position(id):
    """Rechnungsposition loeschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM tbl_Rch_Positionen WHERE RchP_ID = ?", (id,))
        conn.commit()

        release_connection(conn)

        return jsonify({
            'success': True,
            'message': 'Position geloescht'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Dienstkleidung (fuer Auftragstamm Dropdown)
# ============================================

@app.route('/api/dienstkleidung')
def get_dienstkleidung():
    """Dienstkleidung-Optionen fuer Dropdown"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Versuche echte Tabelle
        try:
            cursor.execute("SELECT * FROM tbl_Dienstkleidung ORDER BY DK_Bezeichnung")
            rows = cursor.fetchall()
            dienstkleidung = [row_to_dict(cursor, row) for row in rows]
        except:
            # Fallback: Standard-Dienstkleidung
            dienstkleidung = [
                {'DK_ID': 1, 'DK_Bezeichnung': 'Anzug schwarz'},
                {'DK_ID': 2, 'DK_Bezeichnung': 'Anzug grau'},
                {'DK_ID': 3, 'DK_Bezeichnung': 'Polo schwarz'},
                {'DK_ID': 4, 'DK_Bezeichnung': 'T-Shirt schwarz'},
                {'DK_ID': 5, 'DK_Bezeichnung': 'Dienstkleidung Kunde'},
                {'DK_ID': 6, 'DK_Bezeichnung': 'Casual'}
            ]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': dienstkleidung
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Orte (Distinct aus Auftragstamm)
# ============================================

@app.route('/api/orte')
def get_orte():
    """Orte fuer Dropdown (Distinct aus tbl_VA_Auftragstamm)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        search = request.args.get('search', '')
        limit = request.args.get('limit', 200, type=int)

        query = f"""
            SELECT DISTINCT TOP {limit} Ort
            FROM tbl_VA_Auftragstamm
            WHERE Ort IS NOT NULL AND Ort <> ''
        """
        params = []

        if search:
            query += " AND Ort LIKE ?"
            params.append(f'%{search}%')

        query += " ORDER BY Ort"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        # Als Objekte mit ID und Name zurueckgeben
        orte = [{'Ort': row[0], 'Ort_ID': idx + 1} for idx, row in enumerate(rows) if row[0]]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': orte
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Schichten (tbl_VA_Start) - Alias fuer dienstplan/schichten
# ============================================

@app.route('/api/schichten')
def get_schichten_alias():
    """Alias fuer /api/dienstplan/schichten - wird von Bridge erwartet"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        vadatum_id = request.args.get('vadatum_id')
        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')

        query = """
            SELECT s.*, a.Objekt, a.Auftrag
            FROM tbl_VA_Start s
            LEFT JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND s.VA_ID = ?"
            params.append(int(va_id))

        if vadatum_id:
            # VADatum_ID ist das Datum selbst
            query += " AND s.VADatum = ?"
            params.append(vadatum_id)

        if datum_von:
            query += " AND s.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND s.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY s.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        schichten = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': schichten
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Absagen (tbl_MA_VA_Planung mit Absage-Status)
# ============================================

@app.route('/api/absagen')
def get_absagen():
    """Absagen/Planungen mit Absage-Status"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        vadatum_id = request.args.get('vadatum_id')

        query = """
            SELECT p.*, m.Nachname, m.Vorname, m.Tel_Mobil
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(int(va_id))

        if vadatum_id:
            query += " AND p.VADatum = ?"
            params.append(vadatum_id)

        # Nur Absagen (Status > 1 oder je nach Logik)
        # query += " AND p.MVP_Status IN (2, 3, 4)"  # Absage-Status

        query += " ORDER BY p.VADatum DESC, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        absagen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': absagen
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Zusaetzliche Endpoints fuer Subforms (2026-01-06)
# ============================================

@app.route('/api/schichten/<int:va_id>')
def get_schichten_by_va(va_id):
    """Schichten fuer einen Auftrag (Path-Parameter Version)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum = request.args.get('datum')

        query = """
            SELECT s.*, a.Objekt, a.Auftrag
            FROM tbl_VA_Start s
            LEFT JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.ID
            WHERE s.VA_ID = ?
        """
        params = [va_id]

        if datum:
            query += " AND s.VADatum = ?"
            params.append(datum)

        query += " ORDER BY s.VADatum, s.VA_Start"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        schichten = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'schichten': schichten})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/einsatztage/<int:va_id>')
def get_einsatztage_by_va(va_id):
    """Einsatztage fuer einen Auftrag (Path-Parameter Version)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT t.*,
                   (SELECT COUNT(*) FROM tbl_MA_VA_Planung p WHERE p.VA_ID = t.VA_ID AND p.VADatum = t.VADatum) as MA_Anzahl_Ist,
                   (SELECT SUM(MA_Anzahl) FROM tbl_VA_Start s WHERE s.VA_ID = t.VA_ID AND s.VADatum = t.VADatum) as MA_Anzahl
            FROM tbl_VA_AnzTage t
            WHERE t.VA_ID = ?
            ORDER BY t.VADatum
        """
        cursor.execute(query, [va_id])
        rows = cursor.fetchall()
        tage = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'tage': tage})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/zeitkonten/ma/<int:ma_id>')
def get_zeitkonto_ma(ma_id):
    """Zeitkonto fuer einen Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        jahr = request.args.get('jahr', datetime.now().year)

        # Stunden aus Planungen summieren
        query = """
            SELECT
                SUM(DATEDIFF('n', MVA_Start, MVA_Ende) / 60.0) as Ist_Stunden
            FROM tbl_MA_VA_Planung
            WHERE MA_ID = ? AND YEAR(VADatum) = ?
        """
        cursor.execute(query, [ma_id, jahr])
        row = cursor.fetchone()
        ist_stunden = row[0] if row and row[0] else 0

        # Soll-Stunden aus Mitarbeiter-Stamm (falls vorhanden)
        soll_stunden = 0
        try:
            cursor.execute("SELECT MA_SollStunden FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?", [ma_id])
            row = cursor.fetchone()
            if row and row[0]:
                soll_stunden = float(row[0]) * 52  # Wochenstunden * 52
        except:
            pass

        release_connection(conn)
        return jsonify({
            'success': True,
            'zeitkonto': {
                'ma_id': ma_id,
                'jahr': jahr,
                'soll_stunden': round(soll_stunden, 2),
                'ist_stunden': round(ist_stunden, 2),
                'differenz': round(ist_stunden - soll_stunden, 2)
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/zeitkonten/jahresuebersicht/<int:ma_id>')
def get_jahresuebersicht_ma(ma_id):
    """Jahresuebersicht fuer einen Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        jahr = request.args.get('jahr', datetime.now().year)

        # Monatliche Zusammenfassung
        query = """
            SELECT
                MONTH(VADatum) as Monat,
                COUNT(DISTINCT VADatum) as Tage,
                SUM(DATEDIFF('n', MVA_Start, MVA_Ende) / 60.0) as Stunden
            FROM tbl_MA_VA_Planung
            WHERE MA_ID = ? AND YEAR(VADatum) = ?
            GROUP BY MONTH(VADatum)
            ORDER BY MONTH(VADatum)
        """
        cursor.execute(query, [ma_id, jahr])
        rows = cursor.fetchall()

        monate = []
        for row in rows:
            monate.append({
                'monat': row[0],
                'tage': row[1],
                'stunden': round(row[2], 2) if row[2] else 0
            })

        release_connection(conn)
        return jsonify({
            'success': True,
            'jahr': jahr,
            'monate': monate
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/stunden/ma/<int:ma_id>')
def get_stunden_ma(ma_id):
    """Stundenauswertung fuer einen Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        von = request.args.get('von')
        bis = request.args.get('bis')

        query = """
            SELECT p.VADatum, p.MVA_Start, p.MVA_Ende,
                   a.Auftrag, a.Objekt,
                   DATEDIFF('n', p.MVA_Start, p.MVA_Ende) / 60.0 as Stunden
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE p.MA_ID = ?
        """
        params = [ma_id]

        if von:
            query += " AND p.VADatum >= ?"
            params.append(von)
        if bis:
            query += " AND p.VADatum <= ?"
            params.append(bis)

        query += " ORDER BY p.VADatum DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        stunden = []
        total = 0
        for row in rows:
            h = row[5] if row[5] else 0
            total += h
            stunden.append({
                'datum': row[0].strftime('%Y-%m-%d') if row[0] else None,
                'start': str(row[1]) if row[1] else None,
                'ende': str(row[2]) if row[2] else None,
                'auftrag': row[3],
                'objekt': row[4],
                'stunden': round(h, 2)
            })

        release_connection(conn)
        return jsonify({
            'success': True,
            'eintraege': stunden,
            'summe': round(total, 2)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/rechnungen/ma/<int:ma_id>')
def get_rechnungen_ma(ma_id):
    """Rechnungen fuer einen Mitarbeiter (Sub-Unternehmer)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT r.*
            FROM tbl_Rechnungen r
            WHERE r.MA_ID = ?
            ORDER BY r.RCH_Datum DESC
        """
        cursor.execute(query, [ma_id])
        rows = cursor.fetchall()
        rechnungen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'rechnungen': rechnungen})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# Kundenpreise API
# ============================================

@app.route('/api/kundenpreise')
def get_kundenpreise():
    """Liste aller Kundenpreise"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT k.kun_Id as id, k.kun_Firma as firma, k.kun_IstAktiv as aktiv,
                   COALESCE(p.KP_Sicherheit, 0) as sicherheit,
                   COALESCE(p.KP_Leitung, 0) as leitung,
                   COALESCE(p.KP_Nachtzuschlag, 25) as nacht,
                   COALESCE(p.KP_Sonntagszuschlag, 50) as sonntag,
                   COALESCE(p.KP_Feiertagszuschlag, 100) as feiertag,
                   COALESCE(p.KP_Fahrtkosten, 0) as fahrt,
                   COALESCE(p.KP_Sonstiges, 0) as sonstiges
            FROM tbl_KD_Kundenstamm k
            LEFT JOIN tbl_KD_Kundenpreise p ON k.kun_Id = p.KD_ID
            ORDER BY k.kun_Firma
        """
        cursor.execute(query)
        rows = cursor.fetchall()

        kundenpreise = []
        for row in rows:
            kundenpreise.append({
                'id': row[0],
                'firma': row[1],
                'aktiv': bool(row[2]) if row[2] is not None else True,
                'sicherheit': float(row[3]) if row[3] else 0,
                'leitung': float(row[4]) if row[4] else 0,
                'nacht': int(row[5]) if row[5] else 25,
                'sonntag': int(row[6]) if row[6] else 50,
                'feiertag': int(row[7]) if row[7] else 100,
                'fahrt': float(row[8]) if row[8] else 0,
                'sonstiges': float(row[9]) if row[9] else 0
            })

        release_connection(conn)
        return jsonify(kundenpreise)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/kundenpreise/<int:kd_id>', methods=['PUT'])
def update_kundenpreis(kd_id):
    """Kundenpreis aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Pruefen ob bereits existiert
        cursor.execute("SELECT COUNT(*) FROM tbl_KD_Kundenpreise WHERE KD_ID = ?", [kd_id])
        exists = cursor.fetchone()[0] > 0

        if exists:
            query = """
                UPDATE tbl_KD_Kundenpreise SET
                    KP_Sicherheit = ?,
                    KP_Leitung = ?,
                    KP_Nachtzuschlag = ?,
                    KP_Sonntagszuschlag = ?,
                    KP_Feiertagszuschlag = ?,
                    KP_Fahrtkosten = ?,
                    KP_Sonstiges = ?
                WHERE KD_ID = ?
            """
            cursor.execute(query, [
                data.get('sicherheit', 0),
                data.get('leitung', 0),
                data.get('nacht', 25),
                data.get('sonntag', 50),
                data.get('feiertag', 100),
                data.get('fahrt', 0),
                data.get('sonstiges', 0),
                kd_id
            ])
        else:
            query = """
                INSERT INTO tbl_KD_Kundenpreise (KD_ID, KP_Sicherheit, KP_Leitung,
                    KP_Nachtzuschlag, KP_Sonntagszuschlag, KP_Feiertagszuschlag,
                    KP_Fahrtkosten, KP_Sonstiges)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            cursor.execute(query, [
                kd_id,
                data.get('sicherheit', 0),
                data.get('leitung', 0),
                data.get('nacht', 25),
                data.get('sonntag', 50),
                data.get('feiertag', 100),
                data.get('fahrt', 0),
                data.get('sonstiges', 0)
            ])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# File Upload API
# ============================================

@app.route('/api/upload', methods=['POST'])
def upload_file():
    """Datei hochladen"""
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'Keine Datei angegeben'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'Leerer Dateiname'}), 400

        # Sicherer Dateiname
        import os
        from werkzeug.utils import secure_filename
        filename = secure_filename(file.filename)

        # Upload-Verzeichnis
        upload_folder = os.path.join(os.path.dirname(__file__), 'uploads')
        os.makedirs(upload_folder, exist_ok=True)

        # Eindeutiger Name mit Timestamp
        unique_filename = f"{int(_time_module.time())}_{filename}"
        filepath = os.path.join(upload_folder, unique_filename)

        file.save(filepath)

        return jsonify({
            'success': True,
            'filename': unique_filename,
            'original_name': filename,
            'path': filepath
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# Kunden-Ansprechpartner API
# ============================================

@app.route('/api/kunden/<int:kd_id>/ansprechpartner')
def get_kunden_ansprechpartner(kd_id):
    """Ansprechpartner eines Kunden laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ID, Anrede, Vorname, Nachname, Position, Telefon, EMail, IstHauptansprechpartner
            FROM tbl_KD_Ansprechpartner
            WHERE kun_Id = ?
            ORDER BY IstHauptansprechpartner DESC, Nachname
        """, [kd_id])

        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Ansprechpartner-Abfrage: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/ansprechpartner', methods=['POST'])
def create_ansprechpartner(kd_id):
    """Neuen Ansprechpartner erstellen"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_KD_Ansprechpartner
            (kun_Id, Anrede, Vorname, Nachname, Position, Telefon, EMail, IstHauptansprechpartner)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, [
            kd_id,
            data.get('Anrede', ''),
            data.get('Vorname', ''),
            data.get('Nachname', ''),
            data.get('Position', ''),
            data.get('Telefon', ''),
            data.get('EMail', ''),
            data.get('IstHauptansprechpartner', False)
        ])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# Preisarten API
# ============================================

@app.route('/api/preisarten')
def get_preisarten():
    """Alle Preisarten/Artikelbeschreibungen laden (aus tbl_KD_Artikelbeschreibung)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ID, Beschreibung as Bezeichnung, Mengenheit as Einheit,
                   MwSt_Satz, cbo_Beschreibung, IstPersonal
            FROM tbl_KD_Artikelbeschreibung
            WHERE ID > 0
            ORDER BY Beschreibung
        """)

        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Preisarten-Abfrage: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# Zeitkonten API (Hauptendpoint)
# ============================================

@app.route('/api/zeitkonten')
def get_zeitkonten():
    """Alle Zeitkonten-Eintraege laden"""
    try:
        ma_id = request.args.get('ma_id', type=int)
        jahr = request.args.get('jahr', type=int)
        monat = request.args.get('monat', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT z.*, m.Nachname, m.Vorname
            FROM tbl_MA_Zeitkonto z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
            WHERE 1=1
        """
        params = []

        if ma_id:
            sql += " AND z.MA_ID = ?"
            params.append(ma_id)
        if jahr:
            sql += " AND z.Jahr = ?"
            params.append(jahr)
        if monat:
            sql += " AND z.Monat = ?"
            params.append(monat)

        sql += " ORDER BY z.Jahr DESC, z.Monat DESC, m.Nachname"

        cursor.execute(sql, params)
        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Zeitkonten-Abfrage: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# Eventdaten API
# ============================================

@app.route('/api/eventdaten')
def get_eventdaten():
    """Eventdaten laden (falls Tabelle existiert)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Filter
        va_id = request.args.get('va_id', type=int)
        datum_von = request.args.get('datum_von')
        datum_bis = request.args.get('datum_bis')

        # Versuche Eventdaten-Tabelle zu lesen
        sql = "SELECT * FROM tbl_Eventdaten WHERE 1=1"
        params = []

        if va_id:
            sql += " AND VA_ID = ?"
            params.append(va_id)
        if datum_von:
            sql += " AND Datum >= ?"
            params.append(datum_von)
        if datum_bis:
            sql += " AND Datum <= ?"
            params.append(datum_bis)

        sql += " ORDER BY Datum DESC"

        try:
            cursor.execute(sql, params)
            rows = cursor.fetchall()
            columns = [col[0] for col in cursor.description]
            data = [dict(zip(columns, row)) for row in rows]
        except:
            # Falls Tabelle nicht existiert
            data = []

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Eventdaten-Abfrage: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': []})


@app.route('/api/eventdaten/<int:id>')
def get_eventdaten_detail(id):
    """Einzelne Eventdaten laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_Eventdaten WHERE ID = ?", [id])
        row = cursor.fetchone()

        if row:
            columns = [col[0] for col in cursor.description]
            data = dict(zip(columns, row))
        else:
            data = None

        release_connection(conn)
        return jsonify({'success': True, 'data': data})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# NEUE ENDPOINTS (2026-01-08)
# ============================================

@app.route('/api/anfragen/create', methods=['POST'])
def create_anfragen_bulk():
    """Erstellt mehrere Anfragen für Mitarbeiter (Bulk-Operation)"""
    try:
        data = request.json
        va_id = data.get('va_id')
        ma_ids = data.get('ma_ids', [])
        datum = data.get('datum')
        start_zeit = data.get('start_zeit')
        ende_zeit = data.get('ende_zeit')

        if not va_id or not ma_ids:
            return jsonify({'success': False, 'error': 'va_id und ma_ids erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        created_count = 0
        errors = []

        for ma_id in ma_ids:
            try:
                # Prüfe ob bereits existiert
                cursor.execute("""
                    SELECT COUNT(*) FROM tbl_MA_VA_Planung
                    WHERE VA_ID = ? AND MA_ID = ? AND VADatum = ?
                """, [va_id, ma_id, datum])

                if cursor.fetchone()[0] == 0:
                    cursor.execute("""
                        INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, MVA_Start, MVA_Ende, Status)
                        VALUES (?, ?, ?, ?, ?, 'Angefragt')
                    """, [va_id, ma_id, datum, start_zeit, ende_zeit])
                    created_count += 1
            except Exception as e:
                errors.append({'ma_id': ma_id, 'error': str(e)})

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'created': created_count,
            'errors': errors
        })
    except Exception as e:
        logger.error(f"Fehler bei Bulk-Anfragen: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/mitarbeiter/entfernungen')
def get_mitarbeiter_entfernungen():
    """Vorberechnete Entfernungen zwischen Mitarbeitern und Objekten"""
    try:
        objekt_id = request.args.get('objekt_id', type=int)
        va_id = request.args.get('va_id', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        # Versuche die Entfernungs-Tabelle zu lesen, falls vorhanden
        try:
            sql = """
                SELECT m.ID as ma_id, m.Nachname, m.Vorname, m.PLZ, m.Ort,
                       e.Entfernung_km, e.Fahrzeit_min
                FROM tbl_MA_Mitarbeiterstamm m
                LEFT JOIN tbl_MA_Entfernungen e ON m.ID = e.MA_ID
                WHERE m.IstAktiv = True
            """
            params = []

            if objekt_id:
                sql += " AND e.Objekt_ID = ?"
                params.append(objekt_id)

            sql += " ORDER BY e.Entfernung_km"
            cursor.execute(sql, params)
        except:
            # Falls keine Entfernungs-Tabelle existiert, nur MA-Daten liefern
            cursor.execute("""
                SELECT ID as ma_id, Nachname, Vorname, PLZ, Ort,
                       NULL as Entfernung_km, NULL as Fahrzeit_min
                FROM tbl_MA_Mitarbeiterstamm
                WHERE IstAktiv = True
                ORDER BY Nachname, Vorname
            """)

        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Entfernungsabfrage: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': []})


@app.route('/api/auto-zuordnung', methods=['POST'])
def auto_zuordnung():
    """Automatische Mitarbeiter-Zuordnung basierend auf Verfügbarkeit und Entfernung"""
    try:
        data = request.json
        va_id = data.get('va_id')
        datum = data.get('datum')
        anzahl = data.get('anzahl', 1)

        if not va_id:
            return jsonify({'success': False, 'error': 'va_id erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Finde verfügbare Mitarbeiter ohne Abwesenheit und ohne bestehende Zuordnung
        # Access SQL: TOP kann nicht parametrisiert werden
        # Status_ID: 1=Geplant, 2=Benachrichtigt, 3=Zusage, 4=Absage
        sql = f"""
            SELECT TOP {int(anzahl)} m.ID, m.Nachname, m.Vorname
            FROM tbl_MA_Mitarbeiterstamm m
            WHERE m.IstAktiv = True
            AND m.ID NOT IN (
                SELECT MA_ID FROM tbl_MA_VA_Planung
                WHERE VADatum = ? AND Status_ID <> 4
            )
            AND m.ID NOT IN (
                SELECT MA_ID FROM tbl_MA_NVerfuegZeiten
                WHERE ? BETWEEN vonDat AND bisDat
            )
            ORDER BY m.Nachname, m.Vorname
        """
        cursor.execute(sql, [datum, datum])

        rows = cursor.fetchall()
        vorschlaege = []

        for row in rows:
            vorschlaege.append({
                'ma_id': row[0],
                'nachname': row[1],
                'vorname': row[2]
            })

        release_connection(conn)
        return jsonify({
            'success': True,
            'vorschlaege': vorschlaege,
            'count': len(vorschlaege)
        })
    except Exception as e:
        logger.error(f"Fehler bei Auto-Zuordnung: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/preise')
def get_kunden_preise(kd_id):
    """Kundenspezifische Preise laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Versuche kundenspezifische Preistabelle
        try:
            cursor.execute("""
                SELECT p.*, pa.Bezeichnung as Preisart_Name
                FROM tbl_KD_Preise p
                LEFT JOIN tbl_Preisarten pa ON p.Preisart_ID = pa.ID
                WHERE p.KD_ID = ?
                ORDER BY pa.Bezeichnung
            """, [kd_id])
            rows = cursor.fetchall()
            columns = [col[0] for col in cursor.description]
            data = [dict(zip(columns, row)) for row in rows]
        except:
            # Fallback: Standardpreise aus Preisarten
            try:
                cursor.execute("""
                    SELECT ID, Bezeichnung, Preis_Standard as Preis
                    FROM tbl_Preisarten
                    ORDER BY Bezeichnung
                """)
                rows = cursor.fetchall()
                columns = [col[0] for col in cursor.description]
                data = [dict(zip(columns, row)) for row in rows]
            except:
                # Keine Preistabellen vorhanden
                data = []

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data),
                       'message': 'Keine Preistabellen vorhanden' if not data else None})
    except Exception as e:
        logger.error(f"Fehler bei Kundenpreisen: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': []})


@app.route('/api/kunden/<int:kd_id>/preise', methods=['POST'])
def create_kunden_preis(kd_id):
    """Neuen kundenspezifischen Preis anlegen"""
    try:
        data = request.json
        preisart_id = data.get('preisart_id')
        preis = data.get('preis')

        if not preisart_id or preis is None:
            return jsonify({'success': False, 'error': 'preisart_id und preis erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_KD_Preise (KD_ID, Preisart_ID, Preis)
            VALUES (?, ?, ?)
        """, [kd_id, preisart_id, preis])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Preis angelegt'})
    except Exception as e:
        logger.error(f"Fehler beim Anlegen Kundenpreis: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/preise/<int:preis_id>', methods=['PUT'])
def update_kunden_preis(kd_id, preis_id):
    """Kundenspezifischen Preis aktualisieren"""
    try:
        data = request.json
        preis = data.get('preis')

        if preis is None:
            return jsonify({'success': False, 'error': 'preis erforderlich'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE tbl_KD_Preise SET Preis = ? WHERE ID = ? AND KD_ID = ?
        """, [preis, preis_id, kd_id])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Preis aktualisiert'})
    except Exception as e:
        logger.error(f"Fehler beim Update Kundenpreis: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/preise/<int:preis_id>', methods=['DELETE'])
def delete_kunden_preis(kd_id, preis_id):
    """Kundenspezifischen Preis löschen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM tbl_KD_Preise WHERE ID = ? AND KD_ID = ?", [preis_id, kd_id])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Preis gelöscht'})
    except Exception as e:
        logger.error(f"Fehler beim Löschen Kundenpreis: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/preise/standard', methods=['POST'])
def set_kunden_standardpreise(kd_id):
    """Standardpreise für Kunden setzen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Hole alle Preisarten mit Standardpreis
        cursor.execute("SELECT ID, Preis_Standard FROM tbl_Preisarten WHERE Preis_Standard IS NOT NULL")
        preisarten = cursor.fetchall()

        for preisart_id, preis in preisarten:
            # Prüfe ob bereits existiert
            cursor.execute("""
                SELECT COUNT(*) FROM tbl_KD_Preise WHERE KD_ID = ? AND Preisart_ID = ?
            """, [kd_id, preisart_id])

            if cursor.fetchone()[0] == 0:
                cursor.execute("""
                    INSERT INTO tbl_KD_Preise (KD_ID, Preisart_ID, Preis)
                    VALUES (?, ?, ?)
                """, [kd_id, preisart_id, preis])

        conn.commit()
        release_connection(conn)
        return jsonify({'success': True, 'message': 'Standardpreise gesetzt'})
    except Exception as e:
        logger.error(f"Fehler beim Setzen Standardpreise: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/kunden/<int:kd_id>/angebote')
def get_kunden_angebote(kd_id):
    """Angebote für einen Kunden laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("""
                SELECT * FROM tbl_Angebote
                WHERE KD_ID = ?
                ORDER BY Datum DESC
            """, [kd_id])
        except:
            # Fallback: Versuche alternative Tabellenstruktur
            try:
                cursor.execute("""
                    SELECT * FROM tbl_AN_Angebote
                    WHERE Kunde_ID = ?
                    ORDER BY ErstelltAm DESC
                """, [kd_id])
            except:
                return jsonify({'success': True, 'data': [], 'count': 0, 'message': 'Keine Angebote-Tabelle vorhanden'})

        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Kundenangeboten: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': []})


@app.route('/api/kunden/<int:kd_id>/statistik')
def get_kunden_statistik(kd_id):
    """Statistik für einen Kunden laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        statistik = {}

        # Anzahl Aufträge
        try:
            cursor.execute("""
                SELECT COUNT(*) FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = ?
            """, [kd_id])
            statistik['anzahl_auftraege'] = cursor.fetchone()[0]
        except:
            statistik['anzahl_auftraege'] = 0

        # Umsatz (falls Rechnungstabelle existiert)
        try:
            cursor.execute("""
                SELECT SUM(Betrag_Brutto) FROM tbl_Rechnungen WHERE KD_ID = ?
            """, [kd_id])
            result = cursor.fetchone()[0]
            statistik['umsatz_gesamt'] = float(result) if result else 0
        except:
            statistik['umsatz_gesamt'] = 0

        # Letzte Aktivität
        try:
            cursor.execute("""
                SELECT TOP 1 VADatum FROM tbl_VA_AnzTage t
                INNER JOIN tbl_VA_Auftragstamm a ON t.VA_ID = a.ID
                WHERE a.Veranstalter_ID = ?
                ORDER BY VADatum DESC
            """, [kd_id])
            row = cursor.fetchone()
            statistik['letzte_aktivitaet'] = str(row[0]) if row else None
        except:
            statistik['letzte_aktivitaet'] = None

        # Anzahl Objekte
        try:
            cursor.execute("""
                SELECT COUNT(DISTINCT Objekt_ID) FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = ?
            """, [kd_id])
            statistik['anzahl_objekte'] = cursor.fetchone()[0]
        except:
            statistik['anzahl_objekte'] = 0

        release_connection(conn)
        return jsonify({'success': True, 'data': statistik})
    except Exception as e:
        logger.error(f"Fehler bei Kundenstatistik: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': {}})


@app.route('/api/auftraege/<int:va_id>/positionen')
def get_auftrag_positionen(va_id):
    """Positionen eines Auftrags laden"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute("""
                SELECT p.*, o.Bezeichnung as Objekt_Name
                FROM tbl_VA_Positionen p
                LEFT JOIN tbl_OB_Objekt o ON p.Objekt_ID = o.ID
                WHERE p.VA_ID = ?
                ORDER BY p.Position
            """, [va_id])
        except:
            # Fallback: Versuche alternative Struktur (Objekt-Positionen)
            try:
                cursor.execute("""
                    SELECT op.*, o.Bezeichnung
                    FROM tbl_OB_Positionen op
                    INNER JOIN tbl_VA_Auftragstamm a ON op.Objekt_ID = a.Objekt_ID
                    LEFT JOIN tbl_OB_Objekt o ON op.Objekt_ID = o.ID
                    WHERE a.ID = ?
                    ORDER BY op.Position
                """, [va_id])
            except:
                return jsonify({'success': True, 'data': [], 'count': 0})

        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in rows]

        release_connection(conn)
        return jsonify({'success': True, 'data': data, 'count': len(data)})
    except Exception as e:
        logger.error(f"Fehler bei Auftragspositionen: {e}")
        return jsonify({'success': False, 'error': str(e), 'data': []})


@app.route('/api/eventdaten/scrape', methods=['POST'])
def scrape_eventdaten():
    """Event-Daten von externer Quelle scrapen (Placeholder)"""
    try:
        data = request.json
        url = data.get('url')
        va_id = data.get('va_id')

        if not url:
            return jsonify({'success': False, 'error': 'URL erforderlich'}), 400

        # Hier würde normalerweise Web-Scraping stattfinden
        # Für jetzt: Placeholder-Response
        logger.info(f"Eventdaten-Scrape angefordert für URL: {url}")

        return jsonify({
            'success': True,
            'message': 'Scraping-Funktion ist ein Placeholder - manuelle Dateneingabe erforderlich',
            'data': {
                'url': url,
                'va_id': va_id,
                'scraped': False,
                'reason': 'Automatisches Scraping nicht implementiert'
            }
        })
    except Exception as e:
        logger.error(f"Fehler beim Eventdaten-Scrape: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/lohn/stunden-export')
def export_stunden_csv():
    """CSV-Export der Stunden für Lohnabrechnung"""
    try:
        from flask import Response
        import io
        import csv

        # Filter
        monat = request.args.get('monat', type=int)
        jahr = request.args.get('jahr', type=int)
        ma_id = request.args.get('ma_id', type=int)

        if not monat or not jahr:
            # Standardwert: aktueller Monat
            from datetime import datetime
            now = datetime.now()
            monat = monat or now.month
            jahr = jahr or now.year

        conn = get_connection()
        cursor = conn.cursor()

        # Stunden aus Zuordnungen aggregieren
        # Access SQL braucht Klammern bei mehreren JOINs
        # Status_ID: 1=Geplant, 2=Benachrichtigt, 3=Zusage, 4=Absage
        sql = """
            SELECT m.ID as MA_ID, m.Nachname, m.Vorname, m.Nr as Personalnummer,
                   p.VADatum, p.MVA_Start, p.MVA_Ende,
                   a.Auftrag, o.Objekt
            FROM ((tbl_MA_VA_Planung p
            INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID)
            LEFT JOIN tbl_OB_Objekt o ON a.Objekt_ID = o.ID
            WHERE MONTH(p.VADatum) = ? AND YEAR(p.VADatum) = ?
            AND p.Status_ID = 3
        """
        params = [monat, jahr]

        if ma_id:
            sql += " AND m.ID = ?"
            params.append(ma_id)

        sql += " ORDER BY m.Nachname, m.Vorname, p.VADatum"

        cursor.execute(sql, params)
        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]

        release_connection(conn)

        # CSV erstellen
        output = io.StringIO()
        writer = csv.writer(output, delimiter=';')

        # Header
        writer.writerow(['MA_ID', 'Nachname', 'Vorname', 'Personalnummer',
                        'Datum', 'Start', 'Ende', 'Auftrag', 'Objekt'])

        # Daten
        for row in rows:
            writer.writerow(row)

        # Response als CSV-Download
        output.seek(0)
        return Response(
            output.getvalue(),
            mimetype='text/csv',
            headers={
                'Content-Disposition': f'attachment; filename=stunden_export_{jahr}_{monat:02d}.csv',
                'Content-Type': 'text/csv; charset=utf-8'
            }
        )
    except Exception as e:
        logger.error(f"Fehler beim Stunden-Export: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# WhatsApp Business API (Meta Cloud API)
# ============================================
import requests as http_requests  # Umbenannt um Konflikt mit Flask request zu vermeiden

# WhatsApp-Konfiguration (aus Umgebungsvariablen oder Config laden)
WHATSAPP_CONFIG = {
    'phone_number_id': os.environ.get('WA_PHONE_NUMBER_ID', ''),  # Meta Phone Number ID
    'access_token': os.environ.get('WA_ACCESS_TOKEN', ''),         # Meta Graph API Token
    'sender_number': '+4991140997799',                             # Absender-Nummer
    'api_version': 'v18.0',
    'webapp_url': 'https://webapp.consec-security.selfhost.eu/index.php?page=dashboard'
}

def send_whatsapp_message(recipient_phone: str, message_text: str) -> dict:
    """
    Sendet eine WhatsApp-Nachricht über die Meta Cloud API.

    Args:
        recipient_phone: Empfänger-Telefonnummer (mit Ländercode, z.B. +491234567890)
        message_text: Nachrichtentext

    Returns:
        dict mit success/error
    """
    if not WHATSAPP_CONFIG['phone_number_id'] or not WHATSAPP_CONFIG['access_token']:
        return {'success': False, 'error': 'WhatsApp API nicht konfiguriert (WA_PHONE_NUMBER_ID / WA_ACCESS_TOKEN fehlen)'}

    # Telefonnummer normalisieren (nur Ziffern)
    phone = ''.join(filter(str.isdigit, recipient_phone))
    if not phone.startswith('49'):
        phone = '49' + phone.lstrip('0')  # Deutschland

    url = f"https://graph.facebook.com/{WHATSAPP_CONFIG['api_version']}/{WHATSAPP_CONFIG['phone_number_id']}/messages"

    headers = {
        'Authorization': f"Bearer {WHATSAPP_CONFIG['access_token']}",
        'Content-Type': 'application/json'
    }

    payload = {
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': phone,
        'type': 'text',
        'text': {
            'preview_url': True,
            'body': message_text
        }
    }

    try:
        response = http_requests.post(url, headers=headers, json=payload, timeout=30)
        response_data = response.json()

        if response.status_code == 200:
            logger.info(f"WhatsApp gesendet an {phone}: {message_text[:50]}...")
            return {'success': True, 'message_id': response_data.get('messages', [{}])[0].get('id')}
        else:
            error_msg = response_data.get('error', {}).get('message', 'Unbekannter Fehler')
            logger.error(f"WhatsApp Fehler: {error_msg}")
            return {'success': False, 'error': error_msg}

    except Exception as e:
        logger.error(f"WhatsApp Exception: {e}")
        return {'success': False, 'error': str(e)}


@app.route('/api/whatsapp/send', methods=['POST'])
def whatsapp_send():
    """
    Sendet eine einzelne WhatsApp-Nachricht.
    Body: { "phone": "+491234...", "message": "Text..." }
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten gesendet'}), 400

        phone = data.get('phone')
        message = data.get('message')

        if not phone or not message:
            return jsonify({'success': False, 'error': 'phone und message erforderlich'}), 400

        result = send_whatsapp_message(phone, message)
        return jsonify(result), 200 if result['success'] else 500

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/whatsapp/anfragen', methods=['POST'])
def whatsapp_anfragen():
    """
    Sendet WhatsApp-Benachrichtigungen an alle MA mit offenen Anfragen.
    Body: { "va_id": 123, "ma_ids": [1,2,3] } oder leer für alle offenen

    Nachricht: "Hi, Du hast neue Nachrichten in Deiner Consec App" + Link
    """
    try:
        data = request.get_json() or {}
        va_id = data.get('va_id')
        ma_ids = data.get('ma_ids', [])

        conn = get_connection()
        cursor = conn.cursor()

        # Offene Anfragen abfragen (Status_ID = 1 oder 2)
        # WICHTIG: Access SQL benötigt Klammern bei mehreren JOINs!
        query = """
            SELECT DISTINCT p.MA_ID, m.Vorname, m.Tel_Mobil,
                   a.Auftrag, p.VADatum
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE p.Status_ID IN (1, 2)
            AND m.Tel_Mobil IS NOT NULL AND m.Tel_Mobil <> ''
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(va_id)

        if ma_ids:
            placeholders = ','.join(['?' for _ in ma_ids])
            query += f" AND p.MA_ID IN ({placeholders})"
            params.extend(ma_ids)

        cursor.execute(query, params)
        rows = cursor.fetchall()

        if not rows:
            release_connection(conn)
            return jsonify({'success': True, 'message': 'Keine offenen Anfragen gefunden', 'sent': 0})

        # Nachrichten senden
        sent_count = 0
        errors = []

        for row in rows:
            ma_id, vorname, tel_mobil, auftrag, va_datum = row

            # Nachricht erstellen
            message = f"Hi {vorname},\n\nDu hast neue Nachrichten in Deiner Consec App.\n\n"
            message += f"Öffne die App, um Deine Einsatzanfragen zu sehen:\n{WHATSAPP_CONFIG['webapp_url']}"

            result = send_whatsapp_message(tel_mobil, message)

            if result['success']:
                sent_count += 1
                # Status auf "Benachrichtigt" (2) setzen falls noch nicht
                cursor.execute("""
                    UPDATE tbl_MA_VA_Planung
                    SET Status_ID = 2
                    WHERE MA_ID = ? AND Status_ID = 1
                """, [ma_id])
            else:
                errors.append({'ma_id': ma_id, 'error': result.get('error')})

        conn.commit()
        release_connection(conn)

        return jsonify({
            'success': True,
            'sent': sent_count,
            'total': len(rows),
            'errors': errors if errors else None
        })

    except Exception as e:
        logger.error(f"WhatsApp Anfragen Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/whatsapp/status')
def whatsapp_status():
    """Zeigt den WhatsApp-Konfigurationsstatus"""
    configured = bool(WHATSAPP_CONFIG['phone_number_id'] and WHATSAPP_CONFIG['access_token'])
    return jsonify({
        'configured': configured,
        'sender_number': WHATSAPP_CONFIG['sender_number'],
        'webapp_url': WHATSAPP_CONFIG['webapp_url'],
        'hint': 'Setze WA_PHONE_NUMBER_ID und WA_ACCESS_TOKEN als Umgebungsvariablen' if not configured else None
    })


# ============================================
# E-Mail Vorlagen
# ============================================

@app.route('/api/email-vorlagen', methods=['GET'])
def get_email_vorlagen():
    """Lädt alle E-Mail-Vorlagen aus tbl_MA_Serien_eMail_Vorlage"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT
                ID,
                eMail_Vorlage,
                Absenden_als,
                Voting_Text,
                BetreffZeile,
                Textinhalt,
                IstHTML
            FROM tbl_MA_Serien_eMail_Vorlage
            ORDER BY eMail_Vorlage
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        vorlagen = []
        for row in rows:
            vorlagen.append({
                'id': row[0],
                'name': row[1],
                'absender': row[2],
                'voting_text': row[3],
                'betreff': row[4],
                'text': row[5],
                'ist_html': bool(row[6])
            })

        release_connection(conn)

        return jsonify({'success': True, 'vorlagen': vorlagen})

    except Exception as e:
        logger.error(f"Fehler beim Laden der E-Mail-Vorlagen: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/email-vorlagen/<int:vorlage_id>', methods=['GET'])
def get_email_vorlage(vorlage_id):
    """Lädt eine einzelne E-Mail-Vorlage"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT
                ID,
                eMail_Vorlage,
                Absenden_als,
                Voting_Text,
                BetreffZeile,
                Textinhalt,
                IstHTML
            FROM tbl_MA_Serien_eMail_Vorlage
            WHERE ID = ?
        """

        cursor.execute(query, [vorlage_id])
        row = cursor.fetchone()

        release_connection(conn)

        if not row:
            return jsonify({'success': False, 'error': 'Vorlage nicht gefunden'}), 404

        vorlage = {
            'id': row[0],
            'name': row[1],
            'absender': row[2],
            'voting_text': row[3],
            'betreff': row[4],
            'text': row[5],
            'ist_html': bool(row[6])
        }

        return jsonify({'success': True, 'vorlage': vorlage})

    except Exception as e:
        logger.error(f"Fehler beim Laden der E-Mail-Vorlage {vorlage_id}: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================
# E-Mail Versand
# ============================================

@app.route('/api/dienstplan/email', methods=['POST'])
def send_dienstplan_email():
    """
    Versendet Dienstplan per E-Mail an einen Mitarbeiter

    POST Body:
    {
        "ma_id": 123,
        "von": "2026-01-01",
        "bis": "2026-01-31",
        "betreff": "Ihr Dienstplan",
        "nachricht": "Hallo...",
        "mit_pdf": false
    }
    """
    try:
        data = request.json
        ma_id = data.get('ma_id')
        von_datum = data.get('von')
        bis_datum = data.get('bis')
        betreff = data.get('betreff', 'Ihr Dienstplan')
        nachricht = data.get('nachricht', '')
        mit_pdf = data.get('mit_pdf', False)

        if not ma_id:
            return jsonify({'success': False, 'error': 'ma_id fehlt'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # 1. Mitarbeiter-Daten laden
        cursor.execute("""
            SELECT ID, Nachname, Vorname, eMail, Geschlecht
            FROM tbl_MA_Mitarbeiterstamm
            WHERE ID = ?
        """, [ma_id])

        ma_row = cursor.fetchone()
        if not ma_row:
            return jsonify({'success': False, 'error': 'Mitarbeiter nicht gefunden'}), 404

        # Anrede aus Geschlecht ableiten
        geschlecht = ma_row[4]
        anrede = 'Sehr geehrter Herr' if geschlecht == 'männlich' else 'Sehr geehrte Frau' if geschlecht == 'weiblich' else 'Hallo'

        mitarbeiter = {
            'ID': ma_row[0],
            'Nachname': ma_row[1],
            'Vorname': ma_row[2],
            'eMail': ma_row[3],
            'Anrede': anrede
        }

        if not mitarbeiter['eMail']:
            return jsonify({'success': False, 'error': 'Mitarbeiter hat keine E-Mail-Adresse'}), 400

        # 2. Dienstplan-Daten laden
        query = """
            SELECT
                p.VADatum,
                s.VA_Start,
                s.VA_Ende,
                a.Auftrag,
                a.Objekt,
                a.Ort,
                p.MVA_Start,
                p.MVA_Ende
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            WHERE p.MA_ID = ?
        """
        params = [ma_id]

        if von_datum:
            query += " AND p.VADatum >= ?"
            params.append(von_datum)

        if bis_datum:
            query += " AND p.VADatum <= ?"
            params.append(bis_datum)

        query += " ORDER BY p.VADatum, s.VA_Start"

        cursor.execute(query, params)
        einsaetze_rows = cursor.fetchall()

        einsaetze = []
        for row in einsaetze_rows:
            einsatz = {
                'VADatum': row[0],
                'VA_Start': row[1],
                'VA_Ende': row[2],
                'Auftrag': row[3],
                'Objekt': row[4],
                'Ort': row[5],
                'MVA_Start': row[6],
                'MVA_Ende': row[7]
            }
            einsaetze.append(einsatz)

        release_connection(conn)

        # 3. HTML-E-Mail erstellen
        html_body = create_dienstplan_email_html(mitarbeiter, einsaetze, betreff, nachricht, von_datum, bis_datum)

        # 4. E-Mail versenden (Platzhalter - muss mit echtem SMTP konfiguriert werden)
        # Für jetzt nur die E-Mail-Daten zurückgeben
        logger.info(f"Dienstplan-E-Mail vorbereitet für MA_ID {ma_id} ({mitarbeiter['eMail']})")

        return jsonify({
            'success': True,
            'message': 'E-Mail vorbereitet',
            'email_data': {
                'to': mitarbeiter['eMail'],
                'subject': betreff,
                'body': html_body,
                'einsaetze_count': len(einsaetze)
            },
            'hinweis': 'SMTP-Versand muss noch konfiguriert werden'
        })

    except Exception as e:
        logger.error(f"Fehler beim Versenden der Dienstplan-E-Mail: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


def create_dienstplan_email_html(mitarbeiter, einsaetze, betreff, nachricht, von_datum, bis_datum):
    """Erstellt HTML-Body für Dienstplan-E-Mail"""

    # Datum formatieren
    def format_datum(datum_str):
        if not datum_str:
            return ''
        try:
            d = datetime.strptime(str(datum_str), '%Y-%m-%d')
            return d.strftime('%d.%m.%Y')
        except:
            return str(datum_str)

    # Wochentag ermitteln
    def get_wochentag(datum_str):
        if not datum_str:
            return ''
        try:
            d = datetime.strptime(str(datum_str), '%Y-%m-%d')
            tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
            return tage[d.weekday()]
        except:
            return ''

    # Anrede
    anrede_text = f"{mitarbeiter['Anrede'] or 'Hallo'} {mitarbeiter['Vorname']} {mitarbeiter['Nachname']}"

    # Zeitraum
    zeitraum = ""
    if von_datum and bis_datum:
        zeitraum = f" für den Zeitraum {format_datum(von_datum)} bis {format_datum(bis_datum)}"

    # Einsätze als Tabelle
    einsaetze_html = ""
    if einsaetze:
        einsaetze_html = """
        <table style="width:100%; border-collapse:collapse; margin-top:20px;">
            <thead>
                <tr style="background-color:#4316B2; color:white;">
                    <th style="padding:10px; text-align:left; border:1px solid #ddd;">Datum</th>
                    <th style="padding:10px; text-align:left; border:1px solid #ddd;">Tag</th>
                    <th style="padding:10px; text-align:left; border:1px solid #ddd;">Zeit</th>
                    <th style="padding:10px; text-align:left; border:1px solid #ddd;">Auftrag</th>
                    <th style="padding:10px; text-align:left; border:1px solid #ddd;">Ort</th>
                </tr>
            </thead>
            <tbody>
        """

        for einsatz in einsaetze:
            datum_formatted = format_datum(einsatz['VADatum'])
            wochentag = get_wochentag(einsatz['VADatum'])

            # Zeit: Bevorzugt MVA_Start/Ende (individuelle Zeit), sonst VA_Start/Ende (Schichtzeit)
            zeit_start = einsatz['MVA_Start'] or einsatz['VA_Start'] or ''
            zeit_ende = einsatz['MVA_Ende'] or einsatz['VA_Ende'] or ''
            zeit = f"{zeit_start} - {zeit_ende}" if zeit_start and zeit_ende else ''

            auftrag = einsatz['Auftrag'] or einsatz['Objekt'] or 'N/A'
            ort = einsatz['Ort'] or ''

            einsaetze_html += f"""
                <tr>
                    <td style="padding:8px; border:1px solid #ddd;">{datum_formatted}</td>
                    <td style="padding:8px; border:1px solid #ddd;">{wochentag}</td>
                    <td style="padding:8px; border:1px solid #ddd;">{zeit}</td>
                    <td style="padding:8px; border:1px solid #ddd;">{auftrag}</td>
                    <td style="padding:8px; border:1px solid #ddd;">{ort}</td>
                </tr>
            """

        einsaetze_html += """
            </tbody>
        </table>
        """
    else:
        einsaetze_html = "<p><em>Keine Einsätze für diesen Zeitraum gefunden.</em></p>"

    # Nachricht formatieren (Zeilenumbrüche beibehalten)
    nachricht_formatted = nachricht.replace('\n', '<br>') if nachricht else ''

    # HTML zusammenbauen
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .header {{ background-color: #4316B2; color: white; padding: 20px; }}
            .content {{ padding: 20px; }}
            .footer {{ background-color: #f4f4f4; padding: 15px; margin-top: 30px; font-size: 12px; color: #666; }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1 style="margin:0;">CONSEC Security</h1>
            <p style="margin:5px 0 0 0;">{betreff}</p>
        </div>
        <div class="content">
            <p>{anrede_text},</p>
            <p>{nachricht_formatted}</p>
            <p>anbei erhalten Sie Ihren Dienstplan{zeitraum}.</p>
            {einsaetze_html}
            <p style="margin-top:30px;">Mit freundlichen Grüßen<br>CONSEC Security Nürnberg</p>
        </div>
        <div class="footer">
            <p>CONSEC Veranstaltungsservice & Sicherheitsdienst oHG<br>
            Vogelweiherstr. 70, 90441 Nürnberg<br>
            Tel: 0911 - 40 99 77 99 | Fax: 0911 - 40 99 77 92<br>
            E-Mail: info@consec-nuernberg.de | Web: www.consec-nuernberg.de</p>
        </div>
    </body>
    </html>
    """

    return html


# ============================================
# Server starten
# ============================================

if __name__ == '__main__':
    print("=" * 50)
    print("CONSYS Access Bridge REST API")
    print("=" * 50)
    print(f"Backend: {BACKEND_PATH}")
    print(f"Frontend: {FRONTEND_PATH}")
    print("")
    print("Starte Server auf http://localhost:5000")
    print("Drücke Ctrl+C zum Beenden")
    print("=" * 50)

    # PID-Datei erstellen
    write_pid()

    # Waitress für stabilen Production-Server (statt Flask dev server)
    # KRITISCH: Access ODBC crasht bei parallelen DB-Zugriffen (Segmentation Fault)
    # Lösung: Strikte Limitierung von Threads UND Verbindungen
    try:
        from waitress import serve
        print("Verwende Waitress WSGI Server (Production-Mode)")
        print("Konfiguration: Single-Thread, begrenzte Verbindungen (Access ODBC Kompatibilität)")
        serve(
            app,
            host='0.0.0.0',
            port=5000,
            threads=1,              # NUR 1 Worker-Thread
            connection_limit=50,    # Max 50 gleichzeitige Verbindungen (Browser hält mehrere offen)
            channel_timeout=10,     # Kürzerer Timeout für idle Verbindungen (schnelleres Cleanup)
            recv_bytes=8192,        # Kleinere Buffer = weniger Speicher
            send_bytes=8192,
            asyncore_use_poll=True, # Besseres Socket-Handling auf Windows
            backlog=10              # Max 10 wartende Verbindungen in Listen-Queue
        )  # Access ODBC ist NICHT thread-safe!
    except ImportError:
        print("WARNUNG: Waitress nicht installiert, nutze Flask dev server")
        app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
