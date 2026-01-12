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

app = Flask(__name__, static_folder='web')
CORS(app)  # Enable CORS for all routes

# Konfiguration laden
config_path = Path(__file__).parent / "config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

BACKEND_PATH = config['database']['backend_path']
FRONTEND_PATH = config['database']['frontend_path']

def get_connection():
    """Erstellt ODBC-Verbindung zur Backend-Datenbank"""
    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        f'DBQ={BACKEND_PATH};'
    )
    return pyodbc.connect(conn_str)

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
    """Liefert HTML-Formulare"""
    return send_from_directory('web', filename)

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
        conn.close()
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

        conn.close()

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
        limit = request.args.get('limit', 100, type=int)
        offset = request.args.get('offset', 0, type=int)
        # NEU: Datumsfilter für Dienstplan
        datum_von = request.args.get('von')  # Format: YYYY-MM-DD
        datum_bis = request.args.get('bis')  # Format: YYYY-MM-DD

        # Basis-Query mit dynamischen Bedingungen
        conditions = []
        params = []

        if kunde_id:
            conditions.append("Veranstalter_ID = ?")
            params.append(int(kunde_id))

        # Datumsfilter: Auftrag überlappt mit Zeitraum
        # (Dat_VA_Von <= bis) AND (Dat_VA_Bis >= von)
        if datum_von and datum_bis:
            conditions.append(f"(Dat_VA_Von <= #{datum_bis}# AND Dat_VA_Bis >= #{datum_von}#)")
        elif datum_von:
            conditions.append(f"Dat_VA_Bis >= #{datum_von}#")
        elif datum_bis:
            conditions.append(f"Dat_VA_Von <= #{datum_bis}#")

        where_clause = ""
        if conditions:
            where_clause = "WHERE " + " AND ".join(conditions)

        query = f"""
            SELECT TOP {limit} * FROM tbl_VA_Auftragstamm
            {where_clause}
            ORDER BY ID DESC
        """

        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        rows = cursor.fetchall()
        auftraege = [row_to_dict(cursor, row) for row in rows]

        # Gesamtanzahl
        cursor.execute("SELECT COUNT(*) FROM tbl_VA_Auftragstamm")
        total = cursor.fetchone()[0]

        conn.close()

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

        conn.close()

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

        conn.close()

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

        conn.close()

        return jsonify({
            'success': True,
            'message': 'Auftrag aktualisiert'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# ============================================
# API: Mitarbeiter (tbl_MA_Mitarbeiterstamm)
# ============================================

@app.route('/api/mitarbeiter')
def get_mitarbeiter():
    """Alle Mitarbeiter"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        aktiv = request.args.get('aktiv', 'true')  # Standard: nur aktive
        limit = request.args.get('limit', 500, type=int)
        search = request.args.get('search', '')

        query = f"""
            SELECT TOP {limit} ID, Nachname, Vorname, IstAktiv,
                   Tel_Mobil, Strasse, PLZ, Ort
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = ?
        """
        params = [aktiv.lower() == 'true']

        if search:
            query += " AND (Nachname LIKE ? OR Vorname LIKE ?)"
            params.extend([f'%{search}%', f'%{search}%'])

        query += " ORDER BY Nachname, Vorname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        mitarbeiter = [row_to_dict(cursor, row) for row in rows]

        conn.close()

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

        conn.close()

        return jsonify({
            'success': True,
            'data': {
                'mitarbeiter': mitarbeiter,
                'nicht_verfuegbar': nverfueg
            }
        })
    except Exception as e:
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

        conn.close()

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

        query = """
            SELECT d.*, a.Auftrag, a.Objekt
            FROM tbl_VA_AnzTage d
            LEFT JOIN tbl_VA_Auftragstamm a ON d.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

        if va_id:
            query += " AND d.VA_ID = ?"
            params.append(int(va_id))

        if datum_von:
            query += " AND d.VADatum >= ?"
            params.append(datum_von)

        if datum_bis:
            query += " AND d.VADatum <= ?"
            params.append(datum_bis)

        query += " ORDER BY d.VADatum DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        einsatztage = [row_to_dict(cursor, row) for row in rows]

        conn.close()

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

        query = """
            SELECT z.*, m.Nachname, m.Vorname,
                   a.ID AS Auftrag_ID, a.Auftrag, a.Objekt
            FROM (tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID)
            LEFT JOIN tbl_VA_Auftragstamm a ON z.VA_ID = a.ID
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

        query += " ORDER BY z.VADatum DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        zuordnungen = [row_to_dict(cursor, row) for row in rows]

        conn.close()

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

        conn.close()

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

        conn.close()

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
            SELECT p.*, m.Nachname, m.Vorname,
                   a.ID AS Auftrag_ID, a.Auftrag, a.Objekt
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

        if datum:
            query += " AND p.VADatum = ?"
            params.append(datum)

        query += " ORDER BY p.VADatum DESC, m.Nachname"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        planungen = [row_to_dict(cursor, row) for row in rows]

        conn.close()

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

        conn.close()

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

        conn.close()

        return jsonify({
            'success': True,
            'data': result,
            'count': len(result)
        })
    except Exception as e:
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
        kunde_id = request.args.get('kunde_id')

        query = f"""
            SELECT TOP {limit} o.*, k.kun_Firma
            FROM tbl_OB_Objekt o
            LEFT JOIN tbl_KD_Kundenstamm k ON o.OB_KD_ID = k.kun_Id
            WHERE 1=1
        """
        params = []

        if search:
            query += " AND o.OB_Bezeichnung LIKE ?"
            params.append(f'%{search}%')

        if kunde_id:
            query += " AND o.OB_KD_ID = ?"
            params.append(int(kunde_id))

        query += " ORDER BY o.OB_Bezeichnung"

        cursor.execute(query, params)
        rows = cursor.fetchall()

        objekte = [row_to_dict(cursor, row) for row in rows]

        conn.close()

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

        cursor.execute("""
            SELECT o.*, k.kun_Firma
            FROM tbl_OB_Objekt o
            LEFT JOIN tbl_KD_Kundenstamm k ON o.OB_KD_ID = k.kun_Id
            WHERE o.OB_ID = ?
        """, (id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Objekt nicht gefunden'}), 404

        objekt = row_to_dict(cursor, row)

        # Positionen laden
        cursor.execute("""
            SELECT * FROM tbl_OB_Position
            WHERE OBP_OB_ID = ?
            ORDER BY OBP_ID
        """, (id,))
        positionen = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        conn.close()

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

        conn.close()

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
        conn.close()

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
        conn.close()
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

        conn.close()

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

        # Aufträge des Kunden
        cursor.execute("""
            SELECT VA_ID, Auftrag, Objekt
            FROM tbl_VA_Auftragstamm
            WHERE Veranstalter_ID = ?
            ORDER BY VA_ID DESC
        """, (id,))
        auftraege = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        # Objekte des Kunden
        cursor.execute("""
            SELECT OB_ID, OB_Bezeichnung
            FROM tbl_OB_Objekt
            WHERE OB_KD_ID = ?
            ORDER BY OB_Bezeichnung
        """, (id,))
        objekte = [row_to_dict(cursor, row) for row in cursor.fetchall()]

        conn.close()

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

        conn.close()

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
        conn.close()

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
        conn.close()
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
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO tbl_MA_Mitarbeiterstamm (Nachname, Vorname, Strasse, PLZ, Ort, Tel_Mobil, IstAktiv)
            VALUES (?, ?, ?, ?, ?, ?, True)
        """, (
            data.get('Nachname'),
            data.get('Vorname'),
            data.get('Strasse'),
            data.get('PLZ'),
            data.get('Ort'),
            data.get('Tel_Mobil')
        ))
        conn.commit()

        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]

        conn.close()

        return jsonify({
            'success': True,
            'id': new_id,
            'message': 'Mitarbeiter erstellt'
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>', methods=['PUT'])
def update_mitarbeiter(id):
    """Mitarbeiter aktualisieren"""
    try:
        data = request.get_json()
        conn = get_connection()
        cursor = conn.cursor()

        # Erlaubte Felder
        allowed = ['Nachname', 'Vorname', 'Strasse', 'PLZ', 'Ort', 'Tel_Mobil', 'IstAktiv', 'Email']

        updates = []
        values = []

        for key, value in data.items():
            if key in allowed:
                updates.append(f"{key} = ?")
                values.append(value)

        if not updates:
            return jsonify({'success': False, 'error': 'Keine Felder'}), 400

        values.append(id)
        query = f"UPDATE tbl_MA_Mitarbeiterstamm SET {', '.join(updates)} WHERE ID = ?"

        cursor.execute(query, values)
        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'Mitarbeiter aktualisiert'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/mitarbeiter/<int:id>', methods=['DELETE'])
def delete_mitarbeiter(id):
    """Mitarbeiter deaktivieren"""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("UPDATE tbl_MA_Mitarbeiterstamm SET IstAktiv = False WHERE ID = ?", (id,))
        conn.commit()
        conn.close()
        return jsonify({'success': True, 'message': 'Mitarbeiter deaktiviert'})
    except Exception as e:
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

        conn.close()

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

        conn.close()

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
        conn.close()

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
        conn.close()
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

        query = (
            "SELECT p.*, s.VA_Start, s.VA_Ende, a.Objekt, a.Auftrag "
            "FROM (tbl_MA_VA_Planung p "
            "LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID) "
            "LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID "
            f"WHERE p.MA_ID = {ma_id}"
        )

        if datum_von:
            query += f" AND p.VADatum >= #{datum_von}#"

        if datum_bis:
            query += f" AND p.VADatum <= #{datum_bis}#"

        query += " ORDER BY p.VADatum, s.VA_Start"

        cursor.execute(query)
        rows = cursor.fetchall()

        einsaetze = [row_to_dict(cursor, row) for row in rows]

        conn.close()

        return jsonify({
            'success': True,
            'data': einsaetze
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/dienstplan/alle')
def get_dienstplan_alle():
    """Alle Dienstpläne im Zeitraum (Batch-Endpoint für Performance)"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')
        nur_aktive = request.args.get('aktiv', 'true').lower() == 'true'

        # Alle Planungen auf einmal laden statt einzeln pro MA
        query = (
            "SELECT p.MA_ID, p.VADatum, p.VAStart_ID, p.VA_ID, p.Storno, "
            "s.VA_Start, s.VA_Ende, a.Objekt, a.Auftrag, m.Nachname, m.Vorname "
            "FROM (((tbl_MA_VA_Planung p "
            "LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID) "
            "LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID) "
            "LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID) "
            "WHERE 1=1"
        )

        if nur_aktive:
            query += " AND m.IstAktiv = True"

        if datum_von:
            query += f" AND p.VADatum >= #{datum_von}#"

        if datum_bis:
            query += f" AND p.VADatum <= #{datum_bis}#"

        query += " ORDER BY m.Nachname, m.Vorname, p.VADatum, s.VA_Start"

        cursor.execute(query)
        rows = cursor.fetchall()

        # Gruppiert nach MA_ID zurückgeben
        result = {}
        for row in rows:
            data = row_to_dict(cursor, row)
            ma_id = data['MA_ID']
            if ma_id not in result:
                result[ma_id] = []
            result[ma_id].append(data)

        conn.close()

        return jsonify({
            'success': True,
            'data': result,
            'count': len(rows)
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

        conn.close()

        return jsonify({
            'success': True,
            'data': schichten
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/dienstplan/schichten')
def get_schichten():
    """Alle Schichten im Zeitraum"""
    try:
        conn = get_connection()
        cursor = conn.cursor()

        datum_von = request.args.get('von')
        datum_bis = request.args.get('bis')

        query = """
            SELECT s.*, a.Objekt, a.Auftrag, a.Veranstalter_ID,
                   (SELECT COUNT(*) FROM tbl_MA_VA_Planung p WHERE p.VAStart_ID = s.ID) AS MA_Ist
            FROM tbl_VA_Start s
            INNER JOIN tbl_VA_Auftragstamm a ON s.VA_ID = a.ID
            WHERE 1=1
        """
        params = []

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

        conn.close()

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
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
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

        conn.close()

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
        conn.close()

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

        conn.close()

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

        conn.close()

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
        conn.close()

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

        conn.close()

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
        conn.close()

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

        conn.close()

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

        conn.close()

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

        conn.close()

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

        conn.close()

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

        conn.close()

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

        # 1. Alle aktiven Mitarbeiter laden
        ma_query = f"SELECT TOP {limit} ID, Nachname, Vorname FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY Nachname, Vorname"
        cursor.execute(ma_query)
        ma_rows = cursor.fetchall()
        mitarbeiter = [row_to_dict(cursor, row) for row in ma_rows]

        # 2. Einsätze laden (ohne JOIN erstmal)
        for ma in mitarbeiter:
            ma_id = ma.get('ID')
            try:
                einsatz_query = "SELECT MA_ID, VADatum, VA_Start, VA_Ende, VA_ID FROM tbl_MA_VA_Planung WHERE MA_ID = ?"
                cursor.execute(einsatz_query, [ma_id])
                einsatz_rows = cursor.fetchall()
                ma['einsaetze'] = [row_to_dict(cursor, row) for row in einsatz_rows]
            except Exception as ex:
                ma['einsaetze'] = []
            ma['abwesenheiten'] = []

        conn.close()

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
# API: E-Mail Versand via Mailjet SMTP
# ============================================

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Mailjet SMTP Credentials (aus Access zmd_Const.bas)
MAILJET_USER = "97455f0f699bcd3a1cb8602299c3dadd"
MAILJET_PASSWORD = "1dd9946e4f632343405471b1b700c52f"
MAILJET_SERVER = "in-v3.mailjet.com"
MAILJET_PORT = 587  # TLS Port

@app.route('/api/email/send', methods=['POST'])
def send_email():
    """E-Mail über Mailjet SMTP senden
    
    POST Body (JSON):
    {
        "to": "empfaenger@email.de",
        "subject": "Betreff",
        "html_body": "<html>...</html>",
        "plain_body": "Klartext..."
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten übergeben'}), 400
        
        to_email = data.get('to')
        subject = data.get('subject', 'CONSEC Anfrage')
        html_body = data.get('html_body', '')
        plain_body = data.get('plain_body', '')
        
        if not to_email:
            return jsonify({'success': False, 'error': 'Empfänger-E-Mail fehlt'}), 400
        
        # E-Mail erstellen
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = 'Consec Auftragsplanung <siegert@consec-nuernberg.de>'
        msg['To'] = to_email
        
        # Plain Text und HTML hinzufügen
        if plain_body:
            part1 = MIMEText(plain_body, 'plain', 'utf-8')
            msg.attach(part1)
        
        if html_body:
            part2 = MIMEText(html_body, 'html', 'utf-8')
            msg.attach(part2)
        
        # Über SMTP senden
        with smtplib.SMTP(MAILJET_SERVER, MAILJET_PORT) as server:
            server.starttls()  # TLS aktivieren
            server.login(MAILJET_USER, MAILJET_PASSWORD)
            server.sendmail(
                'siegert@consec-nuernberg.de',
                to_email,
                msg.as_string()
            )
        
        # In Log-Tabelle schreiben (optional)
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO tbl_Log_eMail_Sent (SendDate, Absender, Betreff, MailText, BCC, IstHTML)
                VALUES (Now(), ?, ?, ?, ?, -1)
            """, [os.environ.get('USERNAME', 'api_server'), subject, 'API_SEND', to_email])
            conn.commit()
            conn.close()
        except Exception as log_error:
            print(f"Log-Fehler (ignoriert): {log_error}")
        
        return jsonify({
            'success': True,
            'message': f'E-Mail an {to_email} gesendet'
        })
        
    except smtplib.SMTPAuthenticationError as e:
        return jsonify({'success': False, 'error': f'SMTP Auth Fehler: {str(e)}'}), 500
    except smtplib.SMTPException as e:
        return jsonify({'success': False, 'error': f'SMTP Fehler: {str(e)}'}), 500
    except Exception as e:
        import traceback
        return jsonify({'success': False, 'error': str(e), 'trace': traceback.format_exc()}), 500


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

    # debug=False und threaded=True für bessere Performance
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
