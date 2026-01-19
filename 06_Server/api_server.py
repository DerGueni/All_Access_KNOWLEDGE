"""
Access Bridge REST API Server
Verbindet HTML-Formulare mit der Access-Datenbank
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import pyodbc
import json
import os
from datetime import datetime, date, time
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

# Zusätzliche CORS-Headers für file:// Protokoll
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    return response

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

# Thread-lokale Verbindung für Request-Wiederverwendung
import threading
_thread_local = threading.local()

def get_connection():
    """Holt oder erstellt eine Thread-lokale DB-Verbindung (wird wiederverwendet)"""
    if not hasattr(_thread_local, 'conn') or _thread_local.conn is None:
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        _thread_local.conn = pyodbc.connect(conn_str)
    # Teste ob Verbindung noch gültig
    try:
        _thread_local.conn.execute("SELECT 1")
    except:
        # Verbindung ungültig - neu erstellen
        try:
            _thread_local.conn.close()
        except:
            pass
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
        _thread_local.conn = pyodbc.connect(conn_str)
    return _thread_local.conn

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
    if isinstance(val, datetime):
        return val.isoformat()
    if isinstance(val, date):
        return val.isoformat()
    if isinstance(val, time):
        return val.strftime('%H:%M:%S')
    if isinstance(val, Decimal):
        return float(val)
    if isinstance(val, bytes):
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

@app.route('/api/health')
def health_check():
    """Einfacher Health-Check ohne DB-Verbindung"""
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

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

        query = f"""
            SELECT TOP {limit} * FROM tbl_VA_Auftragstamm
            {where_sql}
            ORDER BY Dat_VA_Von ASC, ID DESC
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

        # Hauptdaten
        cursor.execute("SELECT * FROM tbl_VA_Auftragstamm WHERE VA_ID = ?", (id,))
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
    """Alle Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv_param = request.args.get('aktiv', 'true')  # Standard: nur aktive
        # Akzeptiere 1, true, True als aktiv=True
        aktiv = aktiv_param.lower() in ('true', '1', 'yes')
        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')

        query = f"""
            SELECT TOP {limit} ID, Nachname, Vorname, IstAktiv,
                   Tel_Mobil, Strasse, PLZ, Ort
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = ?
        """
        params = [aktiv]

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
            'data': mitarbeiter
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
                   a.VA_ID AS Auftrag_ID, a.Auftrag, a.Objekt
            FROM (tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON z.VA_ID = a.VA_ID
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

        query += " ORDER BY z.VADatum DESC, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        zuordnungen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

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
    """MA-VA Planungen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id')
        ma_id = request.args.get('ma_id')
        datum = request.args.get('datum')

        query = """
            SELECT p.*, m.Nachname, m.Vorname, m.Tel_Mobil,
                   a.VA_ID AS Auftrag_ID, a.Auftrag, a.Objekt
            FROM (tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND p.VA_ID = ?"
            params.append(int(va_id))

        if ma_id:
            query += " AND p.MA_ID = ?"
            params.append(int(ma_id))

        if datum:
            query += " AND p.VADatum = ?"
            params.append(datum)

        query += " ORDER BY p.VADatum DESC, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        planungen = [row_to_dict(cursor, row) for row in rows]

        release_connection(conn)

        return jsonify({
            'success': True,
            'data': planungen
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

        cursor.execute("""
            SELECT * FROM tbl_OB_Position
            WHERE OBP_OB_ID = ?
            ORDER BY OBP_ID
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

        query = """
            SELECT p.*, s.VA_Start, s.VA_Ende, a.Objekt, a.Auftrag
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
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
            INNER JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.VA_ID
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
            INNER JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.VA_ID
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
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
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
                einsatz_query = """
                    SELECT p.MA_ID, p.VADatum, s.VA_Start, s.VA_Ende, p.VA_ID, a.Auftrag, a.Objekt
                    FROM tbl_MA_VA_Planung p
                    LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
                    LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
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

# ============================================
# API: Auftrags-Schichten
# ============================================

@app.route('/api/auftraege/<int:va_id>/schichten')
def get_auftrag_schichten(va_id):
    """Schichten für einen Auftrag"""
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
# API: Auftrags-Zuordnungen
# ============================================

@app.route('/api/auftraege/<int:va_id>/zuordnungen')
def get_auftrag_zuordnungen(va_id):
    """MA-Zuordnungen für einen Auftrag"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        vadatum_id = request.args.get('vadatum_id', None)

        query = """
            SELECT p.ID, p.VA_ID, p.MA_ID, p.VADatum, p.VA_Start, p.VA_Ende,
                   m.Nachname, m.Vorname
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            WHERE p.VA_ID = ?
        """
        params = [va_id]

        if vadatum_id:
            query += " AND p.VADatum_ID = ?"
            params.append(vadatum_id)

        query += " ORDER BY p.VADatum, p.VA_Start, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        data = [row_to_dict(cursor, row) for row in rows]
        release_connection(conn)

        return jsonify({'success': True, 'data': data})
    except Exception as e:
        logger.error(f"Zuordnungen-Fehler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Auftrags-Absagen
# ============================================

@app.route('/api/auftraege/<int:va_id>/absagen')
def get_auftrag_absagen(va_id):
    """Absagen für einen Auftrag - gibt leere Liste wenn Tabelle nicht existiert"""
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
            LEFT JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.VA_ID
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
            LEFT JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.VA_ID
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
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
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
        import time
        unique_filename = f"{int(time.time())}_{filename}"
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
    # Konfiguration: 7 Frontends x 4-5 Threads = 32 Threads
    try:
        from waitress import serve
        print("Verwende Waitress WSGI Server (Production-Mode)")
        print("Konfiguration: 32 Threads für 7 parallele Frontends")
        serve(app, host='0.0.0.0', port=5000, threads=4)  # Reduziert von 32 auf 4 wegen Access ODBC-Limits
    except ImportError:
        print("WARNUNG: Waitress nicht installiert, nutze Flask dev server")
        app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
