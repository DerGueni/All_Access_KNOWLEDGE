# -*- coding: utf-8 -*-
"""
HTML Data Server - Bidirektionale Datensynchronisation fuer CONSEC HTML-Formulare
==================================================================================
Startet einen lokalen HTTP-Server der:
1. JSON-Daten fuer HTML-Formulare bereitstellt
2. Aenderungen aus HTML-Formularen entgegennimmt und ins Access-Backend schreibt
3. Logging aller Operationen

Start: python html_data_server.py
Server laeuft auf: http://localhost:8765
"""

import json
import os
import sys
import gzip
import logging
import pyodbc
from datetime import datetime, date, time
from decimal import Decimal
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading

# ============================================================
# KONFIGURATION
# ============================================================

SERVER_PORT = 8765
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_BE_N_Test_Claude_GPT.accdb"
DATA_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\data"
LOG_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\logs"

# Verbindungsstring
CONN_STR = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"

# ============================================================
# LOGGING SETUP
# ============================================================

os.makedirs(LOG_PATH, exist_ok=True)
log_file = os.path.join(LOG_PATH, f"server_{datetime.now().strftime('%Y%m%d')}.log")

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# ============================================================
# HELPER FUNKTIONEN
# ============================================================

def get_db_connection():
    """Erstellt eine neue Datenbankverbindung"""
    try:
        conn = pyodbc.connect(CONN_STR)
        return conn
    except Exception as e:
        logger.error(f"DB-Verbindungsfehler: {e}")
        return None

def escape_sql(value):
    """Escaped einen Wert fuer SQL"""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "True" if value else "False"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    return "'" + str(value).replace("'", "''") + "'"

def json_serial(obj):
    """JSON serializer fuer spezielle Objekte"""
    if isinstance(obj, (datetime, date)):
        return obj.strftime("%d.%m.%Y")
    if isinstance(obj, time):
        return obj.strftime("%H:%M")
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, bytes):
        return None
    raise TypeError(f"Type {type(obj)} not serializable")

# ============================================================
# DATENBANK-OPERATIONEN
# ============================================================

class DatabaseOperations:
    """Alle Datenbankoperationen fuer das Backend"""

    @staticmethod
    def save_mitarbeiter(data):
        """Speichert Mitarbeiterdaten"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            ma_id = data.get('ID')

            if ma_id:
                # UPDATE
                fields = []
                for key, value in data.items():
                    if key != 'ID':
                        fields.append(f"[{key}] = {escape_sql(value)}")

                sql = f"UPDATE tbl_MA_Mitarbeiterstamm SET {', '.join(fields)} WHERE ID = {ma_id}"
            else:
                # INSERT
                columns = [f"[{k}]" for k in data.keys()]
                values = [escape_sql(v) for v in data.values()]
                sql = f"INSERT INTO tbl_MA_Mitarbeiterstamm ({', '.join(columns)}) VALUES ({', '.join(values)})"

            cursor.execute(sql)
            conn.commit()
            logger.info(f"Mitarbeiter gespeichert: ID={ma_id}")
            return {"success": True, "id": ma_id}
        except Exception as e:
            logger.error(f"Fehler beim Speichern Mitarbeiter: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def save_kunde(data):
        """Speichert Kundendaten"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            kun_id = data.get('kun_Id')

            if kun_id:
                # UPDATE
                fields = []
                for key, value in data.items():
                    if key != 'kun_Id':
                        fields.append(f"[{key}] = {escape_sql(value)}")

                sql = f"UPDATE tbl_KD_Kundenstamm SET {', '.join(fields)} WHERE kun_Id = {kun_id}"
            else:
                # INSERT
                columns = [f"[{k}]" for k in data.keys()]
                values = [escape_sql(v) for v in data.values()]
                sql = f"INSERT INTO tbl_KD_Kundenstamm ({', '.join(columns)}) VALUES ({', '.join(values)})"

            cursor.execute(sql)
            conn.commit()
            logger.info(f"Kunde gespeichert: ID={kun_id}")
            return {"success": True, "id": kun_id}
        except Exception as e:
            logger.error(f"Fehler beim Speichern Kunde: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def save_auftrag(data):
        """Speichert Auftragsdaten"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            va_id = data.get('ID')

            if va_id:
                fields = []
                for key, value in data.items():
                    if key != 'ID':
                        fields.append(f"[{key}] = {escape_sql(value)}")

                sql = f"UPDATE tbl_VA_Auftragstamm SET {', '.join(fields)} WHERE ID = {va_id}"
            else:
                columns = [f"[{k}]" for k in data.keys()]
                values = [escape_sql(v) for v in data.values()]
                sql = f"INSERT INTO tbl_VA_Auftragstamm ({', '.join(columns)}) VALUES ({', '.join(values)})"

            cursor.execute(sql)
            conn.commit()
            logger.info(f"Auftrag gespeichert: ID={va_id}")
            return {"success": True, "id": va_id}
        except Exception as e:
            logger.error(f"Fehler beim Speichern Auftrag: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def save_planung(data):
        """Speichert MA-Planung (Schichtzuordnung)"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            plan_id = data.get('ID')

            if plan_id:
                fields = []
                for key, value in data.items():
                    if key != 'ID':
                        fields.append(f"[{key}] = {escape_sql(value)}")

                sql = f"UPDATE tbl_MA_VA_Planung SET {', '.join(fields)} WHERE ID = {plan_id}"
            else:
                # Pflichtfelder fuer neue Planung
                data['Erst_von'] = os.environ.get('USERNAME', 'HTML_Server')
                data['Erst_am'] = datetime.now().strftime("%m/%d/%Y %H:%M:%S")

                columns = [f"[{k}]" for k in data.keys()]
                values = [escape_sql(v) for v in data.values()]
                sql = f"INSERT INTO tbl_MA_VA_Planung ({', '.join(columns)}) VALUES ({', '.join(values)})"

            cursor.execute(sql)
            conn.commit()

            # MA_Anzahl_Ist aktualisieren wenn neue Planung
            if not plan_id and 'VAStart_ID' in data:
                cursor.execute(f"""
                    UPDATE tbl_VA_Start
                    SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist,0) + 1
                    WHERE ID = {data['VAStart_ID']}
                """)
                conn.commit()

            logger.info(f"Planung gespeichert: ID={plan_id}")
            return {"success": True, "id": plan_id}
        except Exception as e:
            logger.error(f"Fehler beim Speichern Planung: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def delete_planung(plan_id):
        """Loescht eine MA-Planung"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()

            # VAStart_ID holen fuer Aktualisierung
            cursor.execute(f"SELECT VAStart_ID FROM tbl_MA_VA_Planung WHERE ID = {plan_id}")
            row = cursor.fetchone()
            va_start_id = row[0] if row else None

            # Loeschen
            cursor.execute(f"DELETE FROM tbl_MA_VA_Planung WHERE ID = {plan_id}")
            conn.commit()

            # MA_Anzahl_Ist aktualisieren
            if va_start_id:
                cursor.execute(f"""
                    UPDATE tbl_VA_Start
                    SET MA_Anzahl_Ist = IIf(Nz(MA_Anzahl_Ist,0) > 0, MA_Anzahl_Ist - 1, 0)
                    WHERE ID = {va_start_id}
                """)
                conn.commit()

            logger.info(f"Planung geloescht: ID={plan_id}")
            return {"success": True}
        except Exception as e:
            logger.error(f"Fehler beim Loeschen Planung: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def save_abwesenheit(data):
        """Speichert eine Abwesenheit"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            abw_id = data.get('ID')

            if abw_id:
                fields = []
                for key, value in data.items():
                    if key != 'ID':
                        fields.append(f"[{key}] = {escape_sql(value)}")

                sql = f"UPDATE tbl_MA_NVerfuegZeiten SET {', '.join(fields)} WHERE ID = {abw_id}"
            else:
                data['Erst_von'] = os.environ.get('USERNAME', 'HTML_Server')
                data['Erst_am'] = datetime.now().strftime("%m/%d/%Y %H:%M:%S")

                columns = [f"[{k}]" for k in data.keys()]
                values = [escape_sql(v) for v in data.values()]
                sql = f"INSERT INTO tbl_MA_NVerfuegZeiten ({', '.join(columns)}) VALUES ({', '.join(values)})"

            cursor.execute(sql)
            conn.commit()
            logger.info(f"Abwesenheit gespeichert: ID={abw_id}")
            return {"success": True, "id": abw_id}
        except Exception as e:
            logger.error(f"Fehler beim Speichern Abwesenheit: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def delete_abwesenheit(abw_id):
        """Loescht eine Abwesenheit"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        try:
            cursor = conn.cursor()
            cursor.execute(f"DELETE FROM tbl_MA_NVerfuegZeiten WHERE ID = {abw_id}")
            conn.commit()
            logger.info(f"Abwesenheit geloescht: ID={abw_id}")
            return {"success": True}
        except Exception as e:
            logger.error(f"Fehler beim Loeschen Abwesenheit: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

    @staticmethod
    def global_search(search_term):
        """Globale Suche ueber alle relevanten Tabellen"""
        conn = get_db_connection()
        if not conn:
            return {"success": False, "error": "Keine Datenbankverbindung"}

        results = {
            "mitarbeiter": [],
            "kunden": [],
            "auftraege": [],
            "success": True
        }

        try:
            cursor = conn.cursor()
            term = search_term.replace("'", "''")

            # Mitarbeiter suchen
            cursor.execute(f"""
                SELECT TOP 20 ID, Nachname, Vorname, Tel_Mobil, Ort, IstAktiv
                FROM tbl_MA_Mitarbeiterstamm
                WHERE Nachname LIKE '%{term}%'
                   OR Vorname LIKE '%{term}%'
                   OR Tel_Mobil LIKE '%{term}%'
                ORDER BY Nachname, Vorname
            """)
            for row in cursor.fetchall():
                results["mitarbeiter"].append({
                    "ID": row[0], "Nachname": row[1], "Vorname": row[2],
                    "Tel_Mobil": row[3], "Ort": row[4], "IstAktiv": row[5]
                })

            # Kunden suchen
            cursor.execute(f"""
                SELECT TOP 20 kun_Id, kun_Firma, kun_Ort, kun_telefon
                FROM tbl_KD_Kundenstamm
                WHERE kun_Firma LIKE '%{term}%'
                   OR kun_Ort LIKE '%{term}%'
                ORDER BY kun_Firma
            """)
            for row in cursor.fetchall():
                results["kunden"].append({
                    "kun_Id": row[0], "kun_Firma": row[1],
                    "kun_Ort": row[2], "kun_telefon": row[3]
                })

            # Auftraege suchen
            cursor.execute(f"""
                SELECT TOP 20 ID, Auftrag, Objekt, Ort
                FROM tbl_VA_Auftragstamm
                WHERE Auftrag LIKE '%{term}%'
                   OR Objekt LIKE '%{term}%'
                ORDER BY Auftrag
            """)
            for row in cursor.fetchall():
                results["auftraege"].append({
                    "ID": row[0], "Auftrag": row[1],
                    "Objekt": row[2], "Ort": row[3]
                })

            logger.info(f"Globale Suche: '{search_term}' -> {len(results['mitarbeiter'])} MA, {len(results['kunden'])} Kunden, {len(results['auftraege'])} Auftraege")
            return results
        except Exception as e:
            logger.error(f"Fehler bei globaler Suche: {e}")
            return {"success": False, "error": str(e)}
        finally:
            conn.close()

# ============================================================
# HTTP REQUEST HANDLER
# ============================================================

class DataServerHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler fuer den Data Server"""

    def send_json_response(self, data, status=200, compress=True):
        """Sendet eine JSON-Response, optional gzip-komprimiert"""
        json_data = json.dumps(data, ensure_ascii=False, default=json_serial).encode('utf-8')

        # Komprimieren wenn gewuenscht und gross genug
        if compress and len(json_data) > 1000:
            compressed = gzip.compress(json_data)
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Encoding', 'gzip')
            self.send_header('Content-Length', len(compressed))
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(compressed)
        else:
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Content-Length', len(json_data))
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json_data)

    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        """Handle GET requests - Daten abrufen"""
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        try:
            # JSON-Dateien aus data-Ordner liefern
            if path.startswith('/data/'):
                filename = path[6:]  # Remove '/data/'
                filepath = os.path.join(DATA_PATH, filename)

                if os.path.exists(filepath):
                    with open(filepath, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    self.send_json_response(data)
                    logger.info(f"GET {path} -> {len(data)} Datensaetze")
                else:
                    self.send_json_response({"error": "Datei nicht gefunden"}, 404)
                return

            # Globale Suche
            if path == '/api/search':
                term = query.get('q', [''])[0]
                if term:
                    result = DatabaseOperations.global_search(term)
                    self.send_json_response(result)
                else:
                    self.send_json_response({"error": "Suchbegriff fehlt"}, 400)
                return

            # Status-Endpoint
            if path == '/api/status':
                self.send_json_response({
                    "status": "running",
                    "backend": BACKEND_PATH,
                    "time": datetime.now().strftime("%d.%m.%Y %H:%M:%S")
                })
                return

            # Liste aller JSON-Dateien
            if path == '/api/files':
                files = []
                for f in os.listdir(DATA_PATH):
                    if f.endswith('.json'):
                        filepath = os.path.join(DATA_PATH, f)
                        files.append({
                            "name": f,
                            "size": os.path.getsize(filepath),
                            "modified": datetime.fromtimestamp(os.path.getmtime(filepath)).strftime("%d.%m.%Y %H:%M")
                        })
                self.send_json_response(files)
                return

            self.send_json_response({"error": "Unbekannter Endpoint"}, 404)

        except Exception as e:
            logger.error(f"GET Fehler: {e}")
            self.send_json_response({"error": str(e)}, 500)

    def do_POST(self):
        """Handle POST requests - Daten speichern"""
        path = self.path
        content_length = int(self.headers.get('Content-Length', 0))

        try:
            body = self.rfile.read(content_length).decode('utf-8')
            data = json.loads(body) if body else {}

            result = {"success": False, "error": "Unbekannter Endpoint"}

            if path == '/api/mitarbeiter':
                result = DatabaseOperations.save_mitarbeiter(data)
            elif path == '/api/kunde':
                result = DatabaseOperations.save_kunde(data)
            elif path == '/api/auftrag':
                result = DatabaseOperations.save_auftrag(data)
            elif path == '/api/planung':
                result = DatabaseOperations.save_planung(data)
            elif path == '/api/abwesenheit':
                result = DatabaseOperations.save_abwesenheit(data)

            status = 200 if result.get('success') else 400
            self.send_json_response(result, status)

        except json.JSONDecodeError as e:
            logger.error(f"JSON Parse Fehler: {e}")
            self.send_json_response({"error": "Ungueltiges JSON"}, 400)
        except Exception as e:
            logger.error(f"POST Fehler: {e}")
            self.send_json_response({"error": str(e)}, 500)

    def do_DELETE(self):
        """Handle DELETE requests"""
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        try:
            result = {"success": False, "error": "Unbekannter Endpoint"}

            if path == '/api/planung':
                plan_id = query.get('id', [None])[0]
                if plan_id:
                    result = DatabaseOperations.delete_planung(int(plan_id))
            elif path == '/api/abwesenheit':
                abw_id = query.get('id', [None])[0]
                if abw_id:
                    result = DatabaseOperations.delete_abwesenheit(int(abw_id))

            status = 200 if result.get('success') else 400
            self.send_json_response(result, status)

        except Exception as e:
            logger.error(f"DELETE Fehler: {e}")
            self.send_json_response({"error": str(e)}, 500)

    def log_message(self, format, *args):
        """Unterdrueckt Standard-Logging (wir haben eigenes)"""
        pass

# ============================================================
# SERVER START
# ============================================================

def start_server():
    """Startet den HTTP Server"""
    server = HTTPServer(('localhost', SERVER_PORT), DataServerHandler)

    print("=" * 60)
    print("CONSEC HTML DATA SERVER")
    print("=" * 60)
    print(f"Server laeuft auf: http://localhost:{SERVER_PORT}")
    print(f"Backend: {BACKEND_PATH}")
    print(f"Data-Ordner: {DATA_PATH}")
    print(f"Log-Datei: {log_file}")
    print()
    print("Endpoints:")
    print("  GET  /data/<filename>.json  - JSON-Daten abrufen (gzip)")
    print("  GET  /api/search?q=<term>   - Globale Suche")
    print("  GET  /api/status            - Server-Status")
    print("  GET  /api/files             - Liste aller JSON-Dateien")
    print("  POST /api/mitarbeiter       - Mitarbeiter speichern")
    print("  POST /api/kunde             - Kunde speichern")
    print("  POST /api/auftrag           - Auftrag speichern")
    print("  POST /api/planung           - Planung speichern")
    print("  POST /api/abwesenheit       - Abwesenheit speichern")
    print("  DELETE /api/planung?id=X    - Planung loeschen")
    print("  DELETE /api/abwesenheit?id=X - Abwesenheit loeschen")
    print()
    print("Druecken Sie Strg+C zum Beenden...")
    print("=" * 60)

    logger.info(f"Server gestartet auf Port {SERVER_PORT}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer wird beendet...")
        logger.info("Server beendet")
        server.shutdown()

if __name__ == "__main__":
    start_server()
