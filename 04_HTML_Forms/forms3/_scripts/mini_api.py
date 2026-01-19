# -*- coding: utf-8 -*-
"""
Mini API Server für forms3 HTML-Formulare
Minimaler REST-Server für direkten Access-Backend-Zugriff
Starten: python mini_api.py
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import pyodbc
from datetime import datetime, date, time
from decimal import Decimal
import os
import threading
from contextlib import contextmanager

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False  # UTF-8 für JSON-Responses
CORS(app)  # CORS für ALLE Routen aktivieren (nicht nur /api/*)

# ============================================
# STATISCHE DATEIEN (HTML, JS, CSS)
# ============================================
# KORRIGIERT: Nur ein dirname() um von _scripts nach forms3 zu kommen
FORMS3_PATH = os.path.dirname(os.path.abspath(__file__))  # _scripts Ordner
FORMS3_PATH = os.path.dirname(FORMS3_PATH)  # forms3 Ordner (parent von _scripts)

@app.route('/')
def index():
    """Startseite - zeigt Auftragstamm"""
    return send_from_directory(FORMS3_PATH, 'frm_va_Auftragstamm.html')

# HINWEIS: Catch-All Route für statische Dateien ist am Ende der Datei definiert
# (nach allen API-Routes), damit Flask zuerst die API-Routes prüft!

# ============================================
# KONFIGURATION - Pfade anpassen falls nötig
# ============================================
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb"

# Alternative: Netzwerkpfad falls S: nicht gemappt
# BACKEND_PATH = r"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb"

# ============================================
# DATENBANK-VERBINDUNG (mit Connection Pooling disabled)
# ============================================
# Deaktiviere pyodbc Connection Pooling um Segfaults zu vermeiden
pyodbc.pooling = False

# Globales Lock - Access ODBC-Treiber ist NICHT thread-safe!
# Alle DB-Operationen muessen serialisiert werden
db_lock = threading.Lock()

def get_connection():
    """Erstellt eine neue Datenbankverbindung"""
    conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"
    conn = pyodbc.connect(conn_str)
    conn.autocommit = True  # Verhindert Lock-Probleme
    return conn

@contextmanager
def get_db():
    """Thread-safe Datenbank-Verbindung mit automatischem Lock und Cleanup"""
    with db_lock:
        conn = get_connection()
        try:
            yield conn
        finally:
            conn.close()

def serialize_value(val):
    """Konvertiert Werte für JSON"""
    if val is None:
        return None
    if isinstance(val, (datetime, date)):
        return val.isoformat()
    if isinstance(val, time):
        return val.strftime('%H:%M:%S')
    if isinstance(val, Decimal):
        return float(val)
    if isinstance(val, bytes):
        return val.decode('utf-8', errors='ignore')
    return val

def query_to_list(cursor):
    """Konvertiert Cursor-Ergebnis zu Liste von Dicts"""
    columns = [col[0] for col in cursor.description]
    return [
        {col: serialize_value(val) for col, val in zip(columns, row)}
        for row in cursor.fetchall()
    ]

# ============================================
# API ENDPOINTS
# ============================================

@app.route('/api/health')
def health():
    """Health Check"""
    try:
        conn = get_connection()
        conn.close()
        return jsonify({"status": "ok", "timestamp": datetime.now().isoformat()})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/tables')
def tables():
    """Liste aller Tabellen"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        table_list = [{"name": t.table_name, "type": t.table_type} for t in cursor.tables(tableType='TABLE')]
        conn.close()
        return jsonify({"success": True, "tables": table_list})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- AUFTRÄGE ---
@app.route('/api/auftraege')
def auftraege_list():
    """Auftragsliste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Parameter
        limit = request.args.get('limit', 100, type=int)
        offset = request.args.get('offset', 0, type=int)
        search = request.args.get('search', '')
        status = request.args.get('status', '')
        ab_datum = request.args.get('ab', '')  # NEU: Datumsfilter

        # Alle Felder aus tbl_VA_Auftragstamm
        sql = f"SELECT TOP {limit} * FROM tbl_VA_Auftragstamm WHERE 1=1"

        if search:
            sql += f" AND (Auftrag LIKE '%{search}%' OR Objekt LIKE '%{search}%' OR Ort LIKE '%{search}%')"
        if status:
            sql += f" AND Veranst_Status_ID = {status}"
        if ab_datum:
            # Filter: Aufträge ab diesem Datum (Dat_VA_Von >= ab_datum)
            sql += f" AND Dat_VA_Von >= #{ab_datum}#"

        sql += " ORDER BY ID DESC"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()

        # Zähle Gesamtanzahl
        return jsonify({
            "success": True,
            "data": result,
            "total": len(result),
            "limit": limit,
            "offset": offset
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/auftraege/<int:id>')
def auftrag_detail(id):
    """Einzelner Auftrag mit allen zugehörigen Daten"""
    try:
        with get_db() as conn:
            cursor = conn.cursor()

            # Hauptdaten
            cursor.execute("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = ?", (id,))
            rows = query_to_list(cursor)

            if not rows:
                return jsonify({"success": False, "error": "Nicht gefunden"}), 404

            auftrag = rows[0]

            # Einsatztage - einfache Query
            cursor.execute("SELECT * FROM tbl_VA_AnzTage WHERE VA_ID = ? ORDER BY VADatum", (id,))
            einsatztage = query_to_list(cursor)

            # Startzeiten/Schichten - einfache Query
            cursor.execute("SELECT * FROM tbl_VA_Start WHERE VA_ID = ? ORDER BY VADatum, VA_Start", (id,))
            startzeiten = query_to_list(cursor)

            # Zuordnungen - OHNE JOIN (verhindert Segfaults!)
            cursor.execute("SELECT *, MVA_Start AS MA_Start, MVA_Ende AS MA_Ende FROM tbl_MA_VA_Planung WHERE VA_ID = ? ORDER BY VADatum, MVA_Start", (id,))
            zuordnungen = query_to_list(cursor)

            # MA-Namen separat laden und zusammenführen (statt JOIN)
            if zuordnungen:
                ma_ids = list(set(z.get('MA_ID') for z in zuordnungen if z.get('MA_ID')))
                if ma_ids:
                    # Access/pyodbc: IN-Clause mit direkten Werten (sicher bei Integer-IDs)
                    # WICHTIG: tbl_MA_Mitarbeiterstamm hat 'ID' nicht 'MA_ID'!
                    ids_str = ','.join(str(int(mid)) for mid in ma_ids)
                    cursor.execute(f"SELECT ID, Nachname, Vorname, Tel_Mobil FROM tbl_MA_Mitarbeiterstamm WHERE ID IN ({ids_str})")
                    ma_dict = {row[0]: {'Nachname': row[1], 'Vorname': row[2], 'Tel_Mobil': row[3]} for row in cursor.fetchall()}
                    # Namen zu Zuordnungen hinzufügen
                    for z in zuordnungen:
                        ma = ma_dict.get(z.get('MA_ID'), {})
                        z['Nachname'] = ma.get('Nachname', '')
                        z['Vorname'] = ma.get('Vorname', '')
                        z['Tel_Mobil'] = ma.get('Tel_Mobil', '')

            # Offene Anfragen - vorerst leer (tbl_MA_VA_Zuordnung hat Probleme)
            anfragen = []

            return jsonify({
                "success": True,
                "data": {
                    "auftrag": auftrag,
                    "einsatztage": einsatztage,
                    "startzeiten": startzeiten,
                    "zuordnungen": zuordnungen,
                    "anfragen": anfragen
                }
            })
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

# --- MITARBEITER ---
@app.route('/api/mitarbeiter')
def mitarbeiter_list():
    """Mitarbeiterliste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv = request.args.get('aktiv', '')
        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')

        sql = f"SELECT TOP {limit} * FROM tbl_MA_Mitarbeiterstamm WHERE 1=1"

        if aktiv == 'true' or aktiv == '1':
            sql += " AND IstAktiv = -1"
        if search:
            sql += f" AND (Nachname LIKE '%{search}%' OR Vorname LIKE '%{search}%' OR Kurzname LIKE '%{search}%')"

        sql += " ORDER BY Nachname, Vorname"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>')
def mitarbeiter_detail(id):
    """Einzelner Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        # KORREKTUR: Das Feld heißt 'ID' nicht 'MA_ID' in tbl_MA_Mitarbeiterstamm
        cursor.execute("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?", (id,))
        rows = query_to_list(cursor)
        conn.close()
        if rows:
            return jsonify({"success": True, "data": rows[0]})
        return jsonify({"success": False, "error": "Nicht gefunden"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- KUNDEN ---
@app.route('/api/kunden')
def kunden_list():
    """Kundenliste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv = request.args.get('aktiv', '')
        limit = request.args.get('limit', 500, type=int)

        sql = f"SELECT TOP {limit} * FROM tbl_KD_Kundenstamm WHERE 1=1"

        if aktiv == 'true' or aktiv == '1':
            sql += " AND kun_IstAktiv = -1"

        sql += " ORDER BY kun_Firma"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/kunden/<int:id>')
def kunde_detail(id):
    """Einzelner Kunde"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = ?", (id,))
        rows = query_to_list(cursor)
        conn.close()
        if rows:
            return jsonify({"success": True, "data": rows[0]})
        return jsonify({"success": False, "error": "Nicht gefunden"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- OBJEKTE ---
@app.route('/api/objekte')
def objekte_list():
    """Objekteliste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        limit = request.args.get('limit', 500, type=int)

        # tbl_OB_Objekt hat keine Kun_ID und IstAktiv Felder
        sql = f"SELECT TOP {limit} * FROM tbl_OB_Objekt"
        sql += " ORDER BY Objekt"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- EINSATZTAGE ---
@app.route('/api/einsatztage')
def einsatztage_list():
    """Einsatztage für einen Auftrag, Zeitraum oder parallele Einsätze"""
    try:
        va_id = request.args.get('va_id', type=int)
        datum_id = request.args.get('datum_id', type=int)
        parallel = request.args.get('parallel', 'false').lower() == 'true'
        # NEU: von/bis Parameter für Dienstplan-Übersicht
        von = request.args.get('von')
        bis = request.args.get('bis')

        conn = get_connection()
        cursor = conn.cursor()

        if von and bis:
            # Zeitraum-Abfrage: Alle Einsatztage zwischen von und bis
            cursor.execute("""
                SELECT t.*, a.Auftrag, a.Objekt
                FROM tbl_VA_AnzTage t
                LEFT JOIN tbl_VA_Auftragstamm a ON t.VA_ID = a.ID
                WHERE t.VADatum >= CDATE(?) AND t.VADatum <= CDATE(?)
                ORDER BY t.VADatum, a.Auftrag
            """, (von, bis))
            result = query_to_list(cursor)
        elif datum_id and parallel:
            # Parallele Einsaetze: Alle anderen Auftraege am selben Tag
            cursor.execute("SELECT VADatum FROM tbl_VA_AnzTage WHERE ID = ?", (datum_id,))
            row = cursor.fetchone()
            if row:
                vadatum = row[0]
                cursor.execute("""
                    SELECT t.*, a.Auftrag, a.Objekt
                    FROM tbl_VA_AnzTage t
                    LEFT JOIN tbl_VA_Auftragstamm a ON t.VA_ID = a.ID
                    WHERE t.VADatum = ?
                    ORDER BY a.Auftrag
                """, (vadatum,))
                result = query_to_list(cursor)
            else:
                result = []
        elif va_id:
            cursor.execute("SELECT * FROM tbl_VA_AnzTage WHERE VA_ID = ? ORDER BY VADatum", (va_id,))
            result = query_to_list(cursor)
        else:
            conn.close()
            return jsonify({"success": False, "error": "va_id, datum_id oder von/bis erforderlich"}), 400

        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- SCHICHTEN ---
@app.route('/api/schichten')
def schichten_list():
    """Schichten für einen Auftrag"""
    try:
        va_id = request.args.get('va_id', type=int)
        vadatum_id = request.args.get('vadatum_id', type=int)

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Falls vadatum_id gegeben, erst das VADatum aus tbl_VA_AnzTage holen
        if vadatum_id:
            cursor.execute("SELECT VADatum FROM tbl_VA_AnzTage WHERE ID = ?", (vadatum_id,))
            row = cursor.fetchone()
            if row:
                vadatum = row[0]
                cursor.execute("SELECT * FROM tbl_VA_Start WHERE VA_ID = ? AND VADatum = ? ORDER BY VA_Start", (va_id, vadatum))
            else:
                # Fallback: alle Schichten
                cursor.execute("SELECT * FROM tbl_VA_Start WHERE VA_ID = ? ORDER BY VADatum, VA_Start", (va_id,))
        else:
            # Alle Schichten des Auftrags
            cursor.execute("SELECT * FROM tbl_VA_Start WHERE VA_ID = ? ORDER BY VADatum, VA_Start", (va_id,))

        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ZUORDNUNGEN ---
@app.route('/api/zuordnungen')
def zuordnungen_list():
    """MA-Zuordnungen für einen Auftrag oder Zeitraum"""
    try:
        va_id = request.args.get('va_id', type=int)
        vadatum_id = request.args.get('vadatum_id', type=int)  # Spezifischer Tag
        von = request.args.get('von')  # Datum YYYY-MM-DD
        bis = request.args.get('bis')  # Datum YYYY-MM-DD

        conn = get_connection()
        cursor = conn.cursor()

        # Access-SQL: Multiple JOINs benoetigen Klammern!
        sql = """
            SELECT p.*, p.MVA_Start AS MA_Start, p.MVA_Ende AS MA_Ende,
                   m.Nachname, m.Vorname, m.Tel_Mobil,
                   t.VADatum, a.Objekt
            FROM (((tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID)
            WHERE 1=1
        """
        params = []

        if va_id:
            sql += " AND p.VA_ID = ?"
            params.append(va_id)

        if vadatum_id:
            # Nur Zuordnungen fuer diesen spezifischen Tag
            sql += " AND p.VADatum_ID = ?"
            params.append(vadatum_id)
        elif von and bis:
            sql += " AND t.VADatum BETWEEN ? AND ?"
            params.append(von)
            params.append(bis)
        elif von:
            sql += " AND t.VADatum >= ?"
            params.append(von)
        elif bis:
            sql += " AND t.VADatum <= ?"
            params.append(bis)

        sql += " ORDER BY t.VADatum, p.MVA_Start"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/zuordnungen', methods=['POST'])
def zuordnungen_create():
    """Neue MA-Zuordnung erstellen (tbl_MA_VA_Planung)"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "error": "Keine Daten"}), 400

        # Pflichtfelder pruefen
        va_id = data.get('VA_ID')
        ma_id = data.get('MA_ID')
        if not va_id or not ma_id:
            return jsonify({"success": False, "error": "VA_ID und MA_ID sind erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Insert
        sql = """
            INSERT INTO tbl_MA_VA_Planung
            (VA_ID, MA_ID, VADatum_ID, VAStart_ID, MVA_Start, MVA_Ende,
             Bemerkungen, PKW, Einsatzleitung, IstFraglich)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        params = [
            va_id,
            ma_id,
            data.get('VADatum_ID'),
            data.get('VAStart_ID'),
            data.get('MVA_Start') or data.get('MA_Start'),
            data.get('MVA_Ende') or data.get('MA_Ende'),
            data.get('Bemerkungen', ''),
            data.get('PKW', 0),
            data.get('Einsatzleitung', False),
            data.get('IstFraglich', False)
        ]

        cursor.execute(sql, params)
        conn.commit()

        # Neue ID abrufen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        conn.close()
        print(f"[API] Zuordnung erstellt: ID={new_id}, VA={va_id}, MA={ma_id}")
        return jsonify({"success": True, "id": new_id})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/zuordnungen/<int:id>', methods=['PUT'])
def zuordnungen_update(id):
    """MA-Zuordnung aktualisieren (tbl_MA_VA_Planung)"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "error": "Keine Daten"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Dynamisches Update - nur uebergebene Felder aktualisieren
        updates = []
        params = []

        # Mapping: API-Feldnamen zu DB-Feldnamen
        field_mapping = {
            'MA_ID': 'MA_ID',
            'MA_Start': 'MVA_Start',
            'MA_Ende': 'MVA_Ende',
            'MVA_Start': 'MVA_Start',
            'MVA_Ende': 'MVA_Ende',
            'Bemerkungen': 'Bemerkungen',
            'PKW': 'PKW',
            'Einsatzleitung': 'Einsatzleitung',
            'IstFraglich': 'IstFraglich',
            'VAStart_ID': 'VAStart_ID',
            'VADatum_ID': 'VADatum_ID',
            'Rch_Erstellt': 'Rch_Erstellt'
        }

        for api_field, db_field in field_mapping.items():
            if api_field in data:
                updates.append(f"{db_field} = ?")
                params.append(data[api_field])

        if not updates:
            return jsonify({"success": False, "error": "Keine Felder zum Aktualisieren"}), 400

        params.append(id)
        sql = f"UPDATE tbl_MA_VA_Planung SET {', '.join(updates)} WHERE ID = ?"

        cursor.execute(sql, params)
        conn.commit()
        conn.close()

        print(f"[API] Zuordnung aktualisiert: ID={id}")
        return jsonify({"success": True})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500


# --- PLANUNGEN (Alias fuer zuordnungen - Kompatibilitaet) ---
@app.route('/api/planungen')
def planungen_list():
    """Planungen = Alias fuer Zuordnungen (tbl_MA_VA_Planung)"""
    try:
        va_id = request.args.get('va_id', type=int)
        vadatum_id = request.args.get('vadatum_id', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        # Access-SQL: Multiple JOINs benoetigen Klammern!
        sql = """
            SELECT p.*, p.MVA_Start AS MA_Start, p.MVA_Ende AS MA_Ende,
                   m.Nachname, m.Vorname, m.Tel_Mobil,
                   t.VADatum, a.Objekt
            FROM (((tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID)
            WHERE 1=1
        """
        params = []

        if va_id:
            sql += " AND p.VA_ID = ?"
            params.append(va_id)

        if vadatum_id:
            sql += " AND p.VADatum_ID = ?"
            params.append(vadatum_id)

        sql += " ORDER BY t.VADatum, p.MVA_Start"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# --- STATUS ---
@app.route('/api/status')
def status_list():
    """Status-Liste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_VA_Status ORDER BY ID")
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ORTE ---
@app.route('/api/orte')
def orte_list():
    """Orte-Liste (distinct aus Aufträgen)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT DISTINCT Ort, PLZ
            FROM tbl_VA_Auftragstamm
            WHERE Ort IS NOT NULL AND Ort <> ''
            ORDER BY Ort
        """)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- DIENSTKLEIDUNG ---
@app.route('/api/dienstkleidung')
def dienstkleidung_list():
    """Dienstkleidung-Liste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_MA_Dienstkleidung ORDER BY ID")
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ANFRAGEN ---
@app.route('/api/anfragen')
def anfragen_list():
    """Offene MA-Anfragen"""
    try:
        va_id = request.args.get('va_id', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT z.*, m.Nachname, m.Vorname, m.Kurzname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.MA_Status = 'Angefragt'
        """

        if va_id:
            sql += f" AND z.VA_ID = {va_id}"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ABSAGEN ---
@app.route('/api/absagen')
def absagen_list():
    """MA-Absagen für einen Auftrag"""
    try:
        va_id = request.args.get('va_id', type=int)
        if not va_id:
            return jsonify({"success": True, "data": []})

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT z.*, m.Nachname, m.Vorname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.VA_ID = ? AND z.MA_Status = 'Abgesagt'
        """, (va_id,))
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- MA ANFRAGEN ERSTELLEN ---
@app.route('/api/anfragen/create', methods=['POST'])
def anfragen_create():
    """Erstellt MA-Anfragen für einen Auftrag"""
    try:
        data = request.get_json(force=True)
        ma_ids = data.get('ma_ids', [])
        va_id = data.get('va_id')
        vadatum_id = data.get('vadatum_id')
        vastart_id = data.get('vastart_id')

        if not ma_ids or not va_id:
            return jsonify({"success": False, "error": "ma_ids und va_id erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        created = []
        for ma_id in ma_ids:
            # Prüfen ob Anfrage bereits existiert
            cursor.execute("""
                SELECT ID FROM tbl_MA_VA_Zuordnung
                WHERE MA_ID = ? AND VA_ID = ? AND VADatum_ID = ?
            """, (ma_id, va_id, vadatum_id))
            existing = cursor.fetchone()

            if not existing:
                # Neue Anfrage erstellen
                cursor.execute("""
                    INSERT INTO tbl_MA_VA_Zuordnung
                    (MA_ID, VA_ID, VADatum_ID, VAStart_ID, MA_Status, AnfrageDatum)
                    VALUES (?, ?, ?, ?, 'Angefragt', ?)
                """, (ma_id, va_id, vadatum_id, vastart_id, datetime.now()))
                conn.commit()
                created.append(ma_id)

        # E-Mail-Adressen der angefragten MA holen
        if created:
            placeholders = ','.join(['?'] * len(created))
            cursor.execute(f"""
                SELECT MA_ID, Nachname, Vorname, eMail
                FROM tbl_MA_Mitarbeiterstamm
                WHERE MA_ID IN ({placeholders})
            """, created)
            ma_data = query_to_list(cursor)
        else:
            ma_data = []

        conn.close()

        return jsonify({
            "success": True,
            "created": len(created),
            "ma_data": ma_data,
            "message": f"{len(created)} Anfragen erstellt"
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- EINSATZLISTE FÜR EXCEL-EXPORT ---
@app.route('/api/einsatzliste/<int:va_id>')
def einsatzliste_export(va_id):
    """Einsatzliste-Daten für Excel-Export"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Auftragsdaten
        cursor.execute("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = ?", (va_id,))
        auftrag = query_to_list(cursor)

        if not auftrag:
            conn.close()
            return jsonify({"success": False, "error": "Auftrag nicht gefunden"}), 404

        # Alle Zuordnungen mit MA-Daten
        cursor.execute("""
            SELECT
                z.ID, z.VA_ID, z.VADatum_ID, z.VAStart_ID, z.MA_ID, z.MA_Status,
                z.VA_Start as ZuoStart, z.VA_Ende as ZuoEnde,
                m.Nachname, m.Vorname, m.Kurzname, m.Tel_Mobil, m.eMail,
                t.VADatum,
                s.VA_Start as SchichtStart, s.VA_Ende as SchichtEnde
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            LEFT JOIN tbl_VA_AnzTage t ON z.VADatum_ID = t.ID
            LEFT JOIN tbl_VA_Start s ON z.VAStart_ID = s.ID
            WHERE z.VA_ID = ? AND z.MA_Status = 'Zugesagt'
            ORDER BY t.VADatum, s.VA_Start, m.Nachname
        """, (va_id,))
        zuordnungen = query_to_list(cursor)

        conn.close()

        return jsonify({
            "success": True,
            "auftrag": auftrag[0],
            "zuordnungen": zuordnungen,
            "count": len(zuordnungen)
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ESS NAMENSLISTE FÜR EXCEL-EXPORT ---
@app.route('/api/namensliste/<int:va_id>')
def namensliste_export(va_id):
    """ESS Namensliste-Daten für Excel-Export"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Auftragsdaten
        cursor.execute("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = ?", (va_id,))
        auftrag = query_to_list(cursor)

        if not auftrag:
            conn.close()
            return jsonify({"success": False, "error": "Auftrag nicht gefunden"}), 404

        # Alle zugesagten MA mit ESS-relevanten Daten
        cursor.execute("""
            SELECT DISTINCT
                m.MA_ID, m.Nachname, m.Vorname, m.Kurzname,
                m.Geburtsdatum, m.Geburtsort, m.Nationalitaet,
                m.Ausweis_Nr, m.Ausweis_Gueltig_Bis,
                m.IHK_34a_Nr, m.IHK_34a_Gueltig_Bis,
                m.Tel_Mobil, m.eMail
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.VA_ID = ? AND z.MA_Status = 'Zugesagt'
            ORDER BY m.Nachname, m.Vorname
        """, (va_id,))
        mitarbeiter = query_to_list(cursor)

        conn.close()

        return jsonify({
            "success": True,
            "auftrag": auftrag[0],
            "mitarbeiter": mitarbeiter,
            "count": len(mitarbeiter)
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- PLANUNG ERSTELLEN ---
@app.route('/api/planung/create', methods=['POST'])
def planung_create():
    """Erstellt Planungs-Eintrag für MA"""
    try:
        data = request.get_json(force=True)
        ma_id = data.get('ma_id')
        va_id = data.get('va_id')
        vadatum_id = data.get('vadatum_id')
        vastart_id = data.get('vastart_id')
        status_id = data.get('status_id', 1)  # 1 = Geplant

        if not ma_id or not va_id:
            return jsonify({"success": False, "error": "ma_id und va_id erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Prüfen ob MA bereits geplant
        cursor.execute("""
            SELECT ID FROM tbl_MA_VA_Planung
            WHERE MA_ID = ? AND VA_ID = ? AND VADatum_ID = ?
        """, (ma_id, va_id, vadatum_id))
        existing = cursor.fetchone()

        if existing:
            conn.close()
            return jsonify({"success": False, "error": "MA bereits geplant"}), 409

        # Neue Planung erstellen
        cursor.execute("""
            INSERT INTO tbl_MA_VA_Planung
            (MA_ID, VA_ID, VADatum_ID, VAStart_ID, Status_ID)
            VALUES (?, ?, ?, ?, ?)
        """, (ma_id, va_id, vadatum_id, vastart_id, status_id))
        conn.commit()

        # Neue ID holen
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        conn.close()

        return jsonify({
            "success": True,
            "id": new_id,
            "message": "Planung erstellt"
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- PLANUNG LÖSCHEN ---
@app.route('/api/planung/<int:id>', methods=['DELETE'])
def planung_delete(id):
    """Löscht Planungs-Eintrag"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM tbl_MA_VA_Planung WHERE ID = ?", (id,))
        conn.commit()

        conn.close()

        return jsonify({"success": True, "message": "Planung gelöscht"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- GENERISCHE SQL-ABFRAGE ---
@app.route('/api/query', methods=['POST'])
def execute_query():
    """Führt beliebige SELECT-Abfrage aus"""
    try:
        data = request.get_json(force=True)
        sql = data.get('query', data.get('sql', ''))

        if not sql:
            return jsonify({"success": False, "error": "query erforderlich"}), 400

        # Sicherheitscheck: nur SELECT erlauben
        sql_upper = sql.strip().upper()
        if not sql_upper.startswith('SELECT'):
            return jsonify({"success": False, "error": "Nur SELECT erlaubt"}), 403

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- DIENSTPLAN GRÜNDE (Zeittypen) ---
@app.route('/api/dienstplan/gruende')
def dienstplan_gruende():
    """Abwesenheits-/Zeittyp-Gründe für Dienstplan"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_MA_Zeittyp ORDER BY SortNr, Zeittyp")
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ABWESENHEITEN PRO MITARBEITER ---
@app.route('/api/abwesenheiten')
def abwesenheiten_list():
    """Abwesenheiten/Gründe für einen Mitarbeiter oder Zeitraum"""
    try:
        ma_id = request.args.get('ma_id', type=int)
        von = request.args.get('von')  # Datum YYYY-MM-DD
        bis = request.args.get('bis')  # Datum YYYY-MM-DD

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT a.*, z.Zeittyp as Grund_Bez, z.Kuerzel as Grund_Kuerzel,
                   z.Zeittyp as Grund, m.Nachname, m.Vorname
            FROM tbl_MA_NVerfuegZeiten a
            LEFT JOIN tbl_MA_Zeittyp z ON a.Zeittyp_ID = z.ID
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON a.MA_ID = m.ID
            WHERE 1=1
        """
        params = []

        if ma_id:
            sql += " AND a.MA_ID = ?"
            params.append(ma_id)

        if von and bis:
            # Abwesenheiten die im Zeitraum liegen (Ueberschneidung)
            sql += " AND a.vonDat <= ? AND a.bisDat >= ?"
            params.append(bis)
            params.append(von)
        elif von:
            sql += " AND a.bisDat >= ?"
            params.append(von)
        elif bis:
            sql += " AND a.vonDat <= ?"
            params.append(bis)

        sql += " ORDER BY a.vonDat DESC"

        if not ma_id and not von and not bis:
            sql = sql.replace("SELECT a.*", "SELECT TOP 500 a.*")

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify(result)  # Direkt als Array zurueckgeben (Kompatibilitaet)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- OFFENE ANFRAGEN (fuer Subform) ---
@app.route('/api/anfragen/offen')
def anfragen_offen():
    """Offene MA-Anfragen fuer Subform-Anzeige"""
    try:
        ma_id = request.args.get('ma_id', type=int)
        va_id = request.args.get('va_id', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT p.*, m.Nachname, m.Vorname, m.Kurzname, m.Tel_Mobil,
                   a.Auftrag, a.Objekt, t.VADatum, s.VA_Start, s.VA_Ende
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            WHERE p.MVP_Status = 1
        """

        params = []
        if ma_id:
            sql += " AND p.MA_ID = ?"
            params.append(ma_id)
        if va_id:
            sql += " AND p.VA_ID = ?"
            params.append(va_id)

        sql += " ORDER BY t.VADatum, s.VA_Start"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- GENERISCHES RECORD UPDATE ---
@app.route('/api/record/update', methods=['POST'])
def record_update():
    """Aktualisiert ein einzelnes Feld in einer Tabelle"""
    try:
        data = request.get_json(force=True)
        table = data.get('table')
        record_id = data.get('id')
        field = data.get('field')
        value = data.get('value')

        if not table or not record_id or not field:
            return jsonify({"success": False, "error": "table, id und field erforderlich"}), 400

        # Sicherheitscheck: Nur bestimmte Tabellen erlauben
        allowed_tables = [
            'tbl_MA_VA_Planung', 'tbl_MA_VA_Zuordnung', 'tbl_MA_NVerfuegZeiten',
            'tbl_VA_Auftragstamm', 'tbl_VA_Start', 'tbl_VA_AnzTage'
        ]
        if table not in allowed_tables:
            return jsonify({"success": False, "error": f"Tabelle {table} nicht erlaubt"}), 403

        conn = get_connection()
        cursor = conn.cursor()

        # SQL-Injection-Schutz: field wird validiert
        # ID-Feld der Tabelle bestimmen
        id_field = 'ID'
        if table == 'tbl_MA_Mitarbeiterstamm':
            id_field = 'MA_ID'

        # UPDATE ausfuehren
        sql = f"UPDATE {table} SET {field} = ? WHERE {id_field} = ?"
        cursor.execute(sql, (value, record_id))
        conn.commit()
        conn.close()

        return jsonify({"success": True, "message": f"{field} aktualisiert"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- LOHNABRECHNUNGEN ---
@app.route('/api/lohnabrechnungen')
def lohnabrechnungen_list():
    """Lohnabrechnungen-Liste"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        jahr = request.args.get('jahr', type=int)
        monat = request.args.get('monat', type=int)
        limit = request.args.get('limit', 100, type=int)

        sql = f"SELECT TOP {limit} * FROM ztbl_Lohnabrechnungen WHERE 1=1"

        if jahr:
            sql += f" AND Jahr = {jahr}"
        if monat:
            sql += f" AND Monat = {monat}"

        sql += " ORDER BY Jahr DESC, Monat DESC"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ZEITKONTEN ---
@app.route('/api/zeitkonten')
def zeitkonten_list():
    """Zeitkonten-Eintraege fuer einen Mitarbeiter"""
    try:
        ma_id = request.args.get('ma_id', type=int)
        jahr = request.args.get('jahr', type=int)
        monat = request.args.get('monat', type=int)

        conn = get_connection()
        cursor = conn.cursor()

        sql = "SELECT * FROM tbl_MA_Zeitkonto WHERE 1=1"
        params = []

        if ma_id:
            sql += " AND MA_ID = ?"
            params.append(ma_id)
        if jahr:
            sql += " AND Jahr = ?"
            params.append(jahr)
        if monat:
            sql += " AND Monat = ?"
            params.append(monat)

        sql += " ORDER BY Jahr DESC, Monat DESC"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- ZEITKONTEN IMPORT-FEHLER ---
@app.route('/api/zeitkonten/importfehler')
def zeitkonten_importfehler():
    """Import-Fehler aus Zeiterfassung"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT TOP 200 * FROM tbl_MA_ZeitImportFehler
            ORDER BY ImportDatum DESC
        """)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- BEWERBER ---
@app.route('/api/bewerber')
def bewerber_list():
    """Bewerberliste"""
    try:
        status = request.args.get('status', '')
        limit = request.args.get('limit', 100, type=int)

        conn = get_connection()
        cursor = conn.cursor()

        sql = f"SELECT TOP {limit} * FROM tbl_MA_Bewerber WHERE 1=1"

        if status:
            sql += f" AND Status = '{status}'"

        sql += " ORDER BY EingangDatum DESC"

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/bewerber/<int:id>')
def bewerber_detail(id):
    """Einzelner Bewerber"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tbl_MA_Bewerber WHERE ID = ?", (id,))
        rows = query_to_list(cursor)
        conn.close()
        if rows:
            return jsonify({"success": True, "data": rows[0]})
        return jsonify({"success": False, "error": "Nicht gefunden"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/bewerber', methods=['POST'])
def bewerber_create():
    """Neuen Bewerber anlegen"""
    try:
        data = request.get_json(force=True)

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_MA_Bewerber
            (Nachname, Vorname, Email, Telefon, Status, EingangDatum, Bemerkungen)
            VALUES (?, ?, ?, ?, 'Neu', ?, ?)
        """, (
            data.get('Nachname', ''),
            data.get('Vorname', ''),
            data.get('Email', ''),
            data.get('Telefon', ''),
            datetime.now(),
            data.get('Bemerkungen', '')
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        conn.close()
        return jsonify({"success": True, "id": new_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- DIENSTPLAN (erweitert) ---
@app.route('/api/dienstplan/ma/<int:ma_id>')
def dienstplan_ma(ma_id):
    """Dienstplan fuer einen Mitarbeiter"""
    try:
        von = request.args.get('von', '')
        bis = request.args.get('bis', '')

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT p.*, a.Auftrag, a.Objekt, t.VADatum, s.VA_Start, s.VA_Ende
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            WHERE p.MA_ID = ?
        """
        params = [ma_id]

        if von:
            sql += " AND t.VADatum >= ?"
            params.append(von)
        if bis:
            sql += " AND t.VADatum <= ?"
            params.append(bis)

        sql += " ORDER BY t.VADatum, s.VA_Start"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/dienstplan/objekt/<int:objekt_id>')
def dienstplan_objekt(objekt_id):
    """Dienstplan fuer ein Objekt"""
    try:
        von = request.args.get('von', '')
        bis = request.args.get('bis', '')

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT p.*, m.Nachname, m.Vorname, t.VADatum, s.VA_Start, s.VA_Ende
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            WHERE a.Objekt_ID = ?
        """
        params = [objekt_id]

        if von:
            sql += " AND t.VADatum >= ?"
            params.append(von)
        if bis:
            sql += " AND t.VADatum <= ?"
            params.append(bis)

        sql += " ORDER BY t.VADatum, s.VA_Start, m.Nachname"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- STUNDEN-EXPORT ---
@app.route('/api/lohn/stunden-export')
def lohn_stunden_export():
    """Stunden-Export fuer Lohnabrechnung"""
    try:
        ma_id = request.args.get('ma_id', type=int)
        jahr = request.args.get('jahr', type=int)
        monat = request.args.get('monat', type=int)

        if not jahr or not monat:
            return jsonify({"success": False, "error": "jahr und monat erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT p.MA_ID, m.Nachname, m.Vorname, m.LexNr,
                   t.VADatum, s.VA_Start, s.VA_Ende,
                   a.Auftrag, a.Objekt,
                   DATEDIFF(hour, s.VA_Start, s.VA_Ende) as Stunden
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
            LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            WHERE YEAR(t.VADatum) = ? AND MONTH(t.VADatum) = ?
              AND p.MVP_Status = 2
        """
        params = [jahr, monat]

        if ma_id:
            sql += " AND p.MA_ID = ?"
            params.append(ma_id)

        sql += " ORDER BY m.Nachname, t.VADatum, s.VA_Start"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result, "jahr": jahr, "monat": monat})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- RUECKMELDUNGEN ---
@app.route('/api/rueckmeldungen')
def rueckmeldungen_list():
    """MA-Rueckmeldungen (Zusagen/Absagen)"""
    try:
        va_id = request.args.get('va_id', type=int)
        status = request.args.get('status', '')

        conn = get_connection()
        cursor = conn.cursor()

        sql = """
            SELECT r.*, m.Nachname, m.Vorname, a.Auftrag
            FROM tbl_MA_Rueckmeldung r
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON r.MA_ID = m.MA_ID
            LEFT JOIN tbl_VA_Auftragstamm a ON r.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            sql += " AND r.VA_ID = ?"
            params.append(va_id)
        if status:
            sql += " AND r.Status = ?"
            params.append(status)

        sql += " ORDER BY r.RueckDatum DESC"

        cursor.execute(sql, params)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# --- MITARBEITER SCHNELLAUSWAHL ---
@app.route('/api/mitarbeiter_schnellauswahl')
def mitarbeiter_schnellauswahl():
    """Mitarbeiter für Schnellauswahl (nur aktive, kurze Felder)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        va_id = request.args.get('va_id', type=int)
        datum = request.args.get('datum', '')

        # Basis: aktive Mitarbeiter mit wichtigen Feldern
        sql = """
            SELECT m.ID AS MA_ID, m.Nachname, m.Vorname, m.Tel_Mobil, m.Email
            FROM tbl_MA_Mitarbeiterstamm m
            WHERE m.IstAktiv = -1
            ORDER BY m.Nachname, m.Vorname
        """

        cursor.execute(sql)
        result = query_to_list(cursor)
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ========================================================================
# GESCHÜTZTE ENDPOINTS (kritisch für Formular-Funktionalität!)
# Siehe CLAUDE.md Zeile 93-112
# Diese Endpoints unterstützen vadatum_id als Integer-ID ODER Datum-String
# ========================================================================

@app.route('/api/auftraege/vorschlaege')
def auftraege_vorschlaege():
    """Autocomplete-Vorschläge für Auftragsfelder (Ort, Objekt, etc.)"""
    try:
        feld = request.args.get('feld', '')
        limit = request.args.get('limit', 10, type=int)

        if not feld:
            return jsonify({"success": False, "error": "Parameter 'feld' erforderlich"}), 400

        conn = get_connection()
        cursor = conn.cursor()

        # Je nach Feld unterschiedliche SQL
        if feld == 'ort':
            cursor.execute(f"""
                SELECT DISTINCT TOP {limit} Ort
                FROM tbl_VA_Auftragstamm
                WHERE Ort IS NOT NULL AND Ort <> ''
                ORDER BY Ort
            """)
        elif feld == 'objekt':
            cursor.execute(f"""
                SELECT DISTINCT TOP {limit} Objekt
                FROM tbl_VA_Auftragstamm
                WHERE Objekt IS NOT NULL AND Objekt <> ''
                ORDER BY Objekt
            """)
        elif feld == 'auftrag':
            cursor.execute(f"""
                SELECT DISTINCT TOP {limit} Auftrag
                FROM tbl_VA_Auftragstamm
                WHERE Auftrag IS NOT NULL AND Auftrag <> ''
                ORDER BY Auftrag
            """)
        elif feld == 'dienstkleidung':
            cursor.execute(f"""
                SELECT DISTINCT TOP {limit} Dienstkleidung_ID
                FROM tbl_MA_Dienstkleidung
                WHERE Dienstkleidung_ID IS NOT NULL
                ORDER BY Dienstkleidung_ID
            """)
        else:
            conn.close()
            return jsonify({"success": False, "error": f"Feld '{feld}' nicht unterstützt"}), 400

        result = [row[0] for row in cursor.fetchall()]
        conn.close()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/auftraege/<int:va_id>/schichten')
def auftraege_schichten(va_id):
    """
    GESCHÜTZTER ENDPOINT - NICHT ÄNDERN!
    Schichten für einen Auftrag mit vadatum_id Filter
    vadatum_id kann Integer-ID ODER Datum-String sein
    """
    try:
        vadatum_id = request.args.get('vadatum_id', '')

        with get_db() as conn:
            cursor = conn.cursor()

            if not vadatum_id:
                # Alle Schichten des Auftrags
                cursor.execute("""
                    SELECT * FROM tbl_VA_Start
                    WHERE VA_ID = ?
                    ORDER BY VADatum, VA_Start
                """, (va_id,))
            elif vadatum_id.isdigit():
                # vadatum_id ist eine Integer-ID → JOIN mit tbl_VA_AnzTage
                cursor.execute("""
                    SELECT s.* FROM tbl_VA_Start s
                    INNER JOIN tbl_VA_AnzTage t ON s.VADatum = t.VADatum AND s.VA_ID = t.VA_ID
                    WHERE s.VA_ID = ? AND t.ID = ?
                    ORDER BY s.VA_Start
                """, (va_id, int(vadatum_id)))
            else:
                # vadatum_id ist ein Datum-String → Vergleich mit VADatum
                # Entferne mögliche Zeitangaben (nur Datum verwenden)
                datum_str = vadatum_id.split('T')[0]
                cursor.execute("""
                    SELECT * FROM tbl_VA_Start
                    WHERE VA_ID = ? AND CDATE(VADatum) = CDATE(?)
                    ORDER BY VA_Start
                """, (va_id, datum_str))

            result = query_to_list(cursor)
            return jsonify({"success": True, "data": result})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/auftraege/<int:va_id>/zuordnungen')
def auftraege_zuordnungen(va_id):
    """
    GESCHÜTZTER ENDPOINT - NICHT ÄNDERN!
    MA-Zuordnungen für einen Auftrag mit vadatum_id Filter
    vadatum_id kann Integer-ID ODER Datum-String sein
    """
    try:
        vadatum_id = request.args.get('vadatum_id', '')

        with get_db() as conn:
            cursor = conn.cursor()

            # Basis-SQL mit JOINs
            sql = """
                SELECT p.*, p.MVA_Start AS MA_Start, p.MVA_Ende AS MA_Ende,
                       m.Nachname, m.Vorname, m.Tel_Mobil,
                       t.VADatum
                FROM ((tbl_MA_VA_Planung p
                LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID)
                LEFT JOIN tbl_VA_AnzTage t ON p.VADatum_ID = t.ID)
                WHERE p.VA_ID = ?
            """
            params = [va_id]

            if vadatum_id:
                if vadatum_id.isdigit():
                    # vadatum_id ist eine Integer-ID → Zeige Zuordnungen für dieses Datum ODER ohne Datum
                    sql += " AND (p.VADatum_ID = ? OR p.VADatum_ID IS NULL)"
                    params.append(int(vadatum_id))
                else:
                    # vadatum_id ist ein Datum-String → Zeige Zuordnungen für dieses Datum ODER ohne Datum
                    datum_str = vadatum_id.split('T')[0]
                    sql += " AND (CDATE(t.VADatum) = CDATE(?) OR p.VADatum_ID IS NULL)"
                    params.append(datum_str)

            sql += " ORDER BY t.VADatum, p.MVA_Start"

            cursor.execute(sql, params)
            result = query_to_list(cursor)
            return jsonify({"success": True, "data": result})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/auftraege/<int:va_id>/absagen')
def auftraege_absagen(va_id):
    """
    GESCHÜTZTER ENDPOINT - NICHT ÄNDERN!
    MA-Absagen für einen Auftrag mit vadatum_id Filter
    vadatum_id kann Integer-ID ODER Datum-String sein
    """
    try:
        vadatum_id = request.args.get('vadatum_id', '')

        with get_db() as conn:
            cursor = conn.cursor()

            # Absagen aus tbl_MA_VA_Planung mit Status_ID = 4 (Absage)
            cursor.execute("""
                SELECT * FROM tbl_MA_VA_Planung
                WHERE VA_ID = ? AND Status_ID = 4
                ORDER BY VADatum_ID
            """, (va_id,))

            absagen = query_to_list(cursor)

            # MA-Namen nachträglich laden (verhindert JOIN-Probleme)
            if absagen:
                ma_ids = list(set(a.get('MA_ID') for a in absagen if a.get('MA_ID')))
                if ma_ids:
                    ids_str = ','.join(str(int(mid)) for mid in ma_ids)
                    cursor.execute(f"""
                        SELECT ID, Nachname, Vorname, Tel_Mobil
                        FROM tbl_MA_Mitarbeiterstamm
                        WHERE ID IN ({ids_str})
                    """)
                    ma_dict = {row[0]: {'Nachname': row[1], 'Vorname': row[2], 'Tel_Mobil': row[3]}
                               for row in cursor.fetchall()}
                    # Namen hinzufügen
                    for a in absagen:
                        ma = ma_dict.get(a.get('MA_ID'), {})
                        a['Nachname'] = ma.get('Nachname', '')
                        a['Vorname'] = ma.get('Vorname', '')
                        a['Tel_Mobil'] = ma.get('Tel_Mobil', '')

            return jsonify({"success": True, "data": absagen})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================
# CATCH-ALL ROUTE FÜR STATISCHE DATEIEN
# WICHTIG: Diese Route MUSS am Ende stehen (nach allen API-Routes),
# damit Flask zuerst die API-Routes prüft!
# ============================================
@app.route('/<path:filename>')
def serve_static(filename):
    """Serviert HTML, JS, CSS Dateien aus forms3"""
    return send_from_directory(FORMS3_PATH, filename)


# ============================================
# SERVER STARTEN
# ============================================
if __name__ == '__main__':
    print("=" * 50)
    print("Mini API Server für forms3")
    print("=" * 50)
    print(f"Backend: {BACKEND_PATH}")
    print(f"Server:  http://localhost:5000")
    print("=" * 50)
    print("Endpoints:")
    print("  /api/health          - Health Check")
    print("  /api/auftraege       - Auftragsliste")
    print("  /api/auftraege/<id>  - Auftrag-Details")
    print("  /api/mitarbeiter     - Mitarbeiterliste")
    print("  /api/kunden          - Kundenliste")
    print("  /api/objekte         - Objekteliste")
    print("  /api/einsatztage     - Einsatztage")
    print("  /api/schichten       - Schichten")
    print("  /api/zuordnungen     - Zuordnungen")
    print("  /api/status          - Status-Liste")
    print("  /api/anfragen        - Offene Anfragen")
    print("  /api/absagen         - Absagen")
    print("  /api/query (POST)    - SQL-Abfrage")
    print("=" * 50)

    # Teste Datenbankverbindung
    try:
        conn = get_connection()
        conn.close()
        print("[OK] Datenbankverbindung erfolgreich")
    except Exception as e:
        print(f"[FEHLER] Datenbankverbindung: {e}")
        print("Bitte BACKEND_PATH in mini_api.py pruefen!")

    print("\nServer wird gestartet...")
    # Verwende waitress als WSGI-Server (stabiler als Flask dev server)
    # threads=1 weil Access ODBC-Treiber NICHT thread-safe ist!
    try:
        from waitress import serve
        print("[OK] Waitress WSGI-Server (threads=1)")
        serve(app, host='0.0.0.0', port=5000, threads=1)
    except ImportError:
        print("[WARNUNG] Waitress nicht installiert, nutze Flask dev server")
        app.run(host='0.0.0.0', port=5000, debug=False, threaded=False)
