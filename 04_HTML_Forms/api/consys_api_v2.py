#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
=============================================================================
CONSYS API Server V2 - Access Backend Bridge für Auftragsverwaltung
=============================================================================
REST API Server für die Kommunikation zwischen HTML-Formularen und 
Access Backend-Datenbank.

TABELLEN:
- tbl_VA_Auftragstamm: Aufträge/Veranstaltungen
- tbl_VA_AnzTage: Einsatztage pro Auftrag
- tbl_VA_Start: Schichten/Zeiten pro Tag
- tbl_MA_VA_Zuordnung: MA-Zuordnungen pro Auftrag/Tag
- tbl_KD_Kundenstamm: Kunden/Auftraggeber
- tbl_MA_Mitarbeiterstamm: Mitarbeiter
- tbl_VA_Status: Status-Definitionen

Erstellt: 29.12.2025 von Claude AI für CONSEC Security
=============================================================================
"""

import os
import sys
import json
import logging
from datetime import datetime, date, time
from decimal import Decimal
from flask import Flask, request, jsonify
from flask_cors import CORS
import pyodbc

# Logging konfigurieren
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # CORS für alle Routen aktivieren

# =============================================================================
# KONFIGURATION
# =============================================================================

# Access Backend Datenbank
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"

# Connection String für 64-bit Access
CONN_STRING = (
    r"DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};"
    f"DBQ={BACKEND_PATH};"
    r"ExtendedAnsiSQL=1;"
)

# =============================================================================
# DATENBANK-VERBINDUNG
# =============================================================================

def get_db_connection():
    """Erstellt eine Datenbankverbindung"""
    return pyodbc.connect(CONN_STRING)

def serialize_value(val):
    """Konvertiert Access-Werte zu JSON-serialisierbaren Typen"""
    if val is None:
        return None
    if isinstance(val, datetime):
        return val.strftime("%d.%m.%Y %H:%M:%S") if val.hour or val.minute else val.strftime("%d.%m.%Y")
    if isinstance(val, date):
        return val.strftime("%d.%m.%Y")
    if isinstance(val, time):
        return val.strftime("%H:%M")
    if isinstance(val, Decimal):
        return float(val)
    if isinstance(val, bytes):
        return val.decode('utf-8', errors='replace')
    return val

def row_to_dict(cursor, row):
    """Konvertiert eine Datenbankzeile zu einem Dictionary"""
    columns = [column[0] for column in cursor.description]
    return {col: serialize_value(val) for col, val in zip(columns, row)}

def execute_query(sql, params=None):
    """Führt eine SQL-Abfrage aus und gibt die Ergebnisse zurück"""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        logger.info(f"SQL: {sql[:200]}...")
        if params:
            logger.info(f"Params: {params}")
            cursor.execute(sql, params)
        else:
            cursor.execute(sql)
        
        if cursor.description:
            rows = cursor.fetchall()
            return [row_to_dict(cursor, row) for row in rows]
        else:
            conn.commit()
            return {"affected_rows": cursor.rowcount}
            
    except Exception as e:
        logger.error(f"SQL Error: {e}")
        logger.error(f"SQL: {sql}")
        raise
    finally:
        if conn:
            conn.close()

# =============================================================================
# API ROUTEN - AUFTRÄGE (tbl_VA_Auftragstamm)
# =============================================================================

@app.route('/api/auftraege', methods=['GET'])
def get_auftraege():
    """
    Listet Aufträge ab einem bestimmten Datum.
    Parameter:
    - datum_von: Startdatum im Format TT.MM.YYYY oder YYYY-MM-DD
    - limit: Max. Anzahl (default 200)
    """
    try:
        limit = request.args.get('limit', 200, type=int)
        datum_von = request.args.get('datum_von')
        
        sql = f"""
            SELECT TOP {limit}
                a.ID,
                a.Auftrag,
                a.Objekt,
                a.Objekt_ID,
                a.Ort,
                a.Dat_VA_Von,
                a.Dat_VA_Bis,
                a.Veranst_Status_ID,
                a.Veranstalter_ID,
                a.Treffpunkt,
                a.Dienstkleidung,
                a.Ansprechpartner,
                a.Fahrtkosten,
                a.Autosend_EL,
                a.Erst_von,
                a.Erst_am,
                a.Aend_von,
                a.Aend_am,
                k.kun_Firma AS Auftraggeber,
                (SELECT SUM(TVA_Soll) FROM tbl_VA_AnzTage WHERE VA_ID = a.ID) AS SollGesamt,
                (SELECT SUM(TVA_Ist) FROM tbl_VA_AnzTage WHERE VA_ID = a.ID) AS IstGesamt
            FROM tbl_VA_Auftragstamm a
            LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
            WHERE 1=1
        """
        
        if datum_von:
            # Versuche verschiedene Datumsformate
            try:
                if '.' in datum_von:
                    parts = datum_von.split('.')
                    datum_access = f"{parts[1]}/{parts[0]}/{parts[2]}"
                else:
                    datum_access = datum_von.replace('-', '/')
                sql += f" AND a.Dat_VA_Von >= #{datum_access}#"
            except:
                logger.warning(f"Ungültiges Datum: {datum_von}")
        
        sql += " ORDER BY a.Dat_VA_Von"
        
        data = execute_query(sql)
        
        # Wochentag hinzufügen
        tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
        for item in data:
            if item.get('Dat_VA_Von'):
                try:
                    datum_str = item['Dat_VA_Von'].split()[0]
                    parts = datum_str.split('.')
                    d = datetime(int(parts[2]), int(parts[1]), int(parts[0]))
                    item['Wochentag'] = f"{tage[d.weekday()]}. {datum_str}"
                except:
                    item['Wochentag'] = item['Dat_VA_Von']
        
        return jsonify({
            "success": True, 
            "data": data, 
            "count": len(data),
            "datum_von": datum_von
        })
        
    except Exception as e:
        logger.error(f"Error in get_auftraege: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/auftraege/<int:va_id>', methods=['GET'])
def get_auftrag_detail(va_id):
    """
    Holt einen einzelnen Auftrag mit allen Details:
    - Auftrag-Stammdaten
    - Einsatztage (tbl_VA_AnzTage)
    - Schichten (tbl_VA_Start)
    - Zuordnungen (tbl_MA_VA_Zuordnung)
    """
    try:
        # Hauptdaten
        sql = """
            SELECT 
                a.ID,
                a.Auftrag,
                a.Objekt,
                a.Objekt_ID,
                a.Ort,
                a.Dat_VA_Von,
                a.Dat_VA_Bis,
                a.Veranst_Status_ID,
                a.Veranstalter_ID,
                a.Treffpunkt,
                a.Treffpunkt2,
                a.Dienstkleidung,
                a.Ansprechpartner,
                a.Fahrtkosten,
                a.Dummy AS PKW_Anzahl,
                a.Autosend_EL,
                a.Bemerkungen,
                a.Erst_von,
                a.Erst_am,
                a.Aend_von,
                a.Aend_am,
                k.kun_Firma AS Auftraggeber
            FROM tbl_VA_Auftragstamm a
            LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
            WHERE a.ID = ?
        """
        
        auftrag_list = execute_query(sql, [va_id])
        if not auftrag_list:
            return jsonify({"success": False, "error": "Auftrag nicht gefunden"}), 404
        
        auftrag = auftrag_list[0]
        
        # Einsatztage (tbl_VA_AnzTage)
        einsatztage_sql = """
            SELECT 
                ID,
                VA_ID,
                VADatum,
                TVA_Soll,
                TVA_Ist,
                TVA_Offen,
                PKW_Anzahl
            FROM tbl_VA_AnzTage
            WHERE VA_ID = ?
            ORDER BY VADatum
        """
        einsatztage = execute_query(einsatztage_sql, [va_id])
        
        # Schichten (tbl_VA_Start)
        schichten_sql = """
            SELECT 
                ID,
                VA_ID,
                VADatum_ID,
                VADatum,
                MA_Anzahl,
                VA_Start,
                VA_Ende,
                MA_Anzahl_Ist,
                Bemerkungen
            FROM tbl_VA_Start
            WHERE VA_ID = ?
            ORDER BY VADatum, VA_Start
        """
        schichten = execute_query(schichten_sql, [va_id])
        
        # Zuordnungen (tbl_MA_VA_Zuordnung)
        zuordnungen_sql = """
            SELECT 
                z.ID,
                z.VA_ID,
                z.VADatum_ID,
                z.VAStart_ID,
                z.PosNr,
                z.MA_ID,
                z.MA_Start,
                z.MA_Ende,
                z.MA_Brutto_Std,
                z.PKW,
                z.Bemerkungen,
                z.IstFraglich,
                z.Einsatzleitung,
                z.VADatum,
                m.MA_Nachname,
                m.MA_Vorname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.VA_ID = ?
            ORDER BY z.VADatum, z.PosNr
        """
        zuordnungen = execute_query(zuordnungen_sql, [va_id])
        
        return jsonify({
            "success": True,
            "data": {
                "auftrag": auftrag,
                "einsatztage": einsatztage,
                "schichten": schichten,
                "zuordnungen": zuordnungen
            }
        })
        
    except Exception as e:
        logger.error(f"Error in get_auftrag_detail: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - EINSATZTAGE (tbl_VA_AnzTage)
# =============================================================================

@app.route('/api/einsatztage', methods=['GET'])
def get_einsatztage():
    """Listet Einsatztage für einen Auftrag"""
    try:
        va_id = request.args.get('va_id', type=int)
        
        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400
        
        sql = """
            SELECT 
                ID,
                VA_ID,
                VADatum,
                TVA_Soll,
                TVA_Ist,
                TVA_Offen,
                PKW_Anzahl
            FROM tbl_VA_AnzTage
            WHERE VA_ID = ?
            ORDER BY VADatum
        """
        
        data = execute_query(sql, [va_id])
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_einsatztage: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - SCHICHTEN (tbl_VA_Start)
# =============================================================================

@app.route('/api/schichten', methods=['GET'])
def get_schichten():
    """Listet Schichten für einen Auftrag/Tag"""
    try:
        va_id = request.args.get('va_id', type=int)
        datum_id = request.args.get('datum_id', type=int)
        
        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400
        
        sql = """
            SELECT 
                ID,
                VA_ID,
                VADatum_ID,
                VADatum,
                MA_Anzahl,
                VA_Start,
                VA_Ende,
                MA_Anzahl_Ist,
                Bemerkungen
            FROM tbl_VA_Start
            WHERE VA_ID = ?
        """
        
        params = [va_id]
        
        if datum_id:
            sql += " AND VADatum_ID = ?"
            params.append(datum_id)
        
        sql += " ORDER BY VADatum, VA_Start"
        
        data = execute_query(sql, params)
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_schichten: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - ZUORDNUNGEN (tbl_MA_VA_Zuordnung)
# =============================================================================

@app.route('/api/zuordnungen', methods=['GET'])
def get_zuordnungen():
    """Listet MA-Zuordnungen für einen Auftrag/Tag"""
    try:
        va_id = request.args.get('va_id', type=int)
        datum_id = request.args.get('datum_id', type=int)
        datum = request.args.get('datum')
        
        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400
        
        sql = """
            SELECT 
                z.ID,
                z.VA_ID,
                z.VADatum_ID,
                z.VAStart_ID,
                z.PosNr,
                z.MA_ID,
                z.MA_Start,
                z.MA_Ende,
                z.MA_Brutto_Std,
                z.PKW,
                z.Bemerkungen,
                z.IstFraglich,
                z.Einsatzleitung,
                z.VADatum,
                z.Info,
                m.MA_Nachname,
                m.MA_Vorname
            FROM tbl_MA_VA_Zuordnung z
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.MA_ID
            WHERE z.VA_ID = ?
        """
        
        params = [va_id]
        
        if datum_id:
            sql += " AND z.VADatum_ID = ?"
            params.append(datum_id)
        elif datum:
            sql += " AND Format(z.VADatum, 'dd.mm.yyyy') = ?"
            params.append(datum)
        
        sql += " ORDER BY z.PosNr"
        
        data = execute_query(sql, params)
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_zuordnungen: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - MITARBEITER (tbl_MA_Mitarbeiterstamm)
# =============================================================================

@app.route('/api/mitarbeiter', methods=['GET'])
def get_mitarbeiter():
    """Listet Mitarbeiter

    Query-Parameter:
    - limit: Max. Anzahl Datensaetze (default 500)
    - aktiv: Nur aktive MA (default true)
    - search: Suche in Nachname/Vorname
    - anstellung: Filter nach Anstellungsart_ID (Komma-separiert, z.B. "3,5")
    - filter_anstellung: true = Default-Filter (3,5), false = alle
    """
    try:
        limit = request.args.get('limit', 500, type=int)
        aktiv = request.args.get('aktiv', 'true')
        search = request.args.get('search', '')
        anstellung = request.args.get('anstellung')
        filter_anstellung = request.args.get('filter_anstellung', 'true')

        sql = f"""
            SELECT TOP {limit}
                ID,
                Nachname,
                Vorname,
                PersNr,
                Strasse,
                PLZ,
                Ort,
                Tel_Mobil,
                Tel_Festnetz AS TelFest,
                Email,
                IstAktiv AS Aktiv,
                Anstellungsart_ID
            FROM tbl_MA_Mitarbeiterstamm
            WHERE 1=1
        """

        if aktiv.lower() == 'true':
            sql += " AND IstAktiv = True"

        # Filter nach Anstellungsart_ID
        if anstellung:
            # Expliziter Filter (z.B. "3,5" oder "3")
            anstellung_list = [a.strip() for a in anstellung.split(',')]
            if len(anstellung_list) == 1:
                sql += f" AND Anstellungsart_ID = {anstellung_list[0]}"
            else:
                sql += f" AND Anstellungsart_ID IN ({','.join(anstellung_list)})"
        elif filter_anstellung.lower() == 'true':
            # Default-Filter: Festangestellte (3) und Minijobber (5)
            sql += " AND Anstellungsart_ID IN (3, 5)"

        if search:
            sql += f" AND (Nachname LIKE '*{search}*' OR Vorname LIKE '*{search}*')"

        # Alphabetisch nach Nachname, dann Vorname sortieren
        sql += " ORDER BY Nachname, Vorname"

        data = execute_query(sql)
        return jsonify({"success": True, "data": data, "count": len(data)})
        
    except Exception as e:
        logger.error(f"Error in get_mitarbeiter: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/mitarbeiter/<int:ma_id>', methods=['GET'])
def get_mitarbeiter_detail(ma_id):
    """Holt einen Mitarbeiter mit allen Details

    Hinweis: Das Feld heisst 'ID' in der Tabelle (nicht MA_ID)
    """
    try:
        sql = """
            SELECT *
            FROM tbl_MA_Mitarbeiterstamm
            WHERE ID = ?
        """

        data = execute_query(sql, [ma_id])
        if not data:
            return jsonify({"success": False, "error": "Mitarbeiter nicht gefunden"}), 404

        return jsonify({"success": True, "data": data[0]})
        
    except Exception as e:
        logger.error(f"Error in get_mitarbeiter_detail: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - KUNDEN (tbl_KD_Kundenstamm)
# =============================================================================

@app.route('/api/kunden', methods=['GET'])
def get_kunden():
    """Listet Kunden"""
    try:
        limit = request.args.get('limit', 300, type=int)
        aktiv = request.args.get('aktiv', 'true')
        
        sql = f"""
            SELECT TOP {limit}
                kun_Id AS ID,
                kun_Firma AS Firma,
                kun_Bezeichnung AS Kuerzel,
                kun_Strasse AS Strasse,
                kun_PLZ AS PLZ,
                kun_Ort AS Ort,
                kun_telefon AS Telefon,
                kun_email AS Email,
                kun_IstAktiv AS Aktiv
            FROM tbl_KD_Kundenstamm
            WHERE 1=1
        """
        
        if aktiv.lower() == 'true':
            sql += " AND kun_IstAktiv = True"
        
        sql += " ORDER BY kun_Firma"
        
        data = execute_query(sql)
        return jsonify({"success": True, "data": data, "count": len(data)})
        
    except Exception as e:
        logger.error(f"Error in get_kunden: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - STATUS (tbl_VA_Status)
# =============================================================================

@app.route('/api/status', methods=['GET'])
def get_status():
    """Listet alle Status-Optionen"""
    try:
        sql = "SELECT ID, Fortschritt AS Name FROM tbl_VA_Status ORDER BY ID"
        data = execute_query(sql)
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_status: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - OBJEKTE (tbl_OB_Objekt)
# =============================================================================

@app.route('/api/objekte', methods=['GET'])
def get_objekte():
    """Listet Objekte"""
    try:
        sql = """
            SELECT 
                OB_ID AS ID,
                OB_Objekt AS Objekt,
                OB_Strasse AS Strasse,
                OB_PLZ AS PLZ,
                OB_Ort AS Ort
            FROM tbl_OB_Objekt
            ORDER BY OB_Objekt
        """
        data = execute_query(sql)
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_objekte: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - DIENSTKLEIDUNG (tbl_MA_Dienstkleidung_Vorlage)
# =============================================================================

@app.route('/api/dienstkleidung', methods=['GET'])
def get_dienstkleidung():
    """Listet Dienstkleidungs-Optionen"""
    try:
        sql = """
            SELECT DISTINCT
                ID,
                DK_Bezeichnung AS Bezeichnung
            FROM tbl_MA_Dienstkleidung_Vorlage
            ORDER BY DK_Bezeichnung
        """
        data = execute_query(sql)
        return jsonify({"success": True, "data": data})
        
    except Exception as e:
        logger.error(f"Error in get_dienstkleidung: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - STATUS COUNTS
# =============================================================================

@app.route('/api/auftraege/status-counts', methods=['GET'])
def get_status_counts():
    """Zählt Aufträge pro Status ab einem Datum"""
    try:
        datum_von = request.args.get('datum_von')
        
        where = ""
        if datum_von:
            try:
                if '.' in datum_von:
                    parts = datum_von.split('.')
                    datum_access = f"{parts[1]}/{parts[0]}/{parts[2]}"
                else:
                    datum_access = datum_von.replace('-', '/')
                where = f"WHERE Dat_VA_Von >= #{datum_access}#"
            except:
                pass
        
        sql = f"""
            SELECT 
                Veranst_Status_ID AS StatusID,
                COUNT(*) AS Anzahl
            FROM tbl_VA_Auftragstamm
            {where}
            GROUP BY Veranst_Status_ID
        """
        
        data = execute_query(sql)
        
        # In Dictionary umwandeln
        counts = {-1: 0, 1: 0, 2: 0, 3: 0, 4: 0}
        for row in data:
            counts[row['StatusID']] = row['Anzahl']
        
        return jsonify({"success": True, "data": counts})
        
    except Exception as e:
        logger.error(f"Error in get_status_counts: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - LOOKUP DATEN (für Dropdowns)
# =============================================================================

@app.route('/api/lookups', methods=['GET'])
def get_lookups():
    """
    Holt alle Lookup-Daten für Dropdowns in einem Request:
    - Status
    - Kunden
    - Objekte
    - Orte
    - Dienstkleidung
    - Mitarbeiter (aktive)
    """
    try:
        # Status
        status = execute_query("SELECT ID, Fortschritt AS Name FROM tbl_VA_Status ORDER BY ID")
        
        # Kunden (aktive)
        kunden = execute_query("""
            SELECT kun_Id AS ID, kun_Firma AS Firma 
            FROM tbl_KD_Kundenstamm 
            WHERE kun_IstAktiv = True 
            ORDER BY kun_Firma
        """)
        
        # Orte (distinct aus Auftragstamm)
        orte = execute_query("SELECT DISTINCT Ort FROM tbl_VA_Auftragstamm WHERE Ort IS NOT NULL ORDER BY Ort")
        orte = [r['Ort'] for r in orte if r['Ort']]
        
        # Dienstkleidung
        kleidung = execute_query("""
            SELECT DISTINCT DK_Bezeichnung AS Bezeichnung 
            FROM tbl_MA_Dienstkleidung_Vorlage 
            ORDER BY DK_Bezeichnung
        """)
        kleidung = [r['Bezeichnung'] for r in kleidung if r['Bezeichnung']]
        
        # Mitarbeiter (aktive, für Zuordnungen)
        mitarbeiter = execute_query("""
            SELECT TOP 500
                MA_ID AS ID, 
                MA_Nachname AS Nachname, 
                MA_Vorname AS Vorname,
                MA_Ort AS Ort
            FROM tbl_MA_Mitarbeiterstamm 
            WHERE MA_Aktiv = True 
            ORDER BY MA_Nachname, MA_Vorname
        """)
        
        return jsonify({
            "success": True,
            "data": {
                "status": status,
                "kunden": kunden,
                "orte": orte,
                "dienstkleidung": kleidung,
                "mitarbeiter": mitarbeiter
            }
        })
        
    except Exception as e:
        logger.error(f"Error in get_lookups: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


# =============================================================================
# API ROUTEN - HEALTH CHECK
# =============================================================================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Prüft ob API und Datenbank erreichbar sind"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM tbl_MA_Mitarbeiterstamm WHERE MA_Aktiv = True")
        ma_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM tbl_VA_Auftragstamm")
        va_count = cursor.fetchone()[0]
        conn.close()
        
        return jsonify({
            "success": True,
            "status": "healthy",
            "database": BACKEND_PATH,
            "counts": {
                "mitarbeiter_aktiv": ma_count,
                "auftraege": va_count
            },
            "timestamp": datetime.now().strftime("%d.%m.%Y %H:%M:%S")
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "status": "unhealthy",
            "error": str(e)
        }), 500


@app.route('/api/ping', methods=['GET'])
def ping():
    """Einfacher Ping-Test"""
    return jsonify({"pong": True, "timestamp": datetime.now().isoformat()})


# =============================================================================
# ERROR HANDLERS
# =============================================================================

@app.errorhandler(404)
def not_found(e):
    return jsonify({"success": False, "error": "Route nicht gefunden"}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({"success": False, "error": "Interner Server-Fehler"}), 500


# =============================================================================
# MAIN
# =============================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("CONSYS API Server V2 - Auftragsverwaltung")
    print("=" * 60)
    print(f"Backend: {BACKEND_PATH}")
    print(f"API Base: http://localhost:5001/api")
    print("=" * 60)
    print("")
    print("Endpoints:")
    print("  GET /api/auftraege?datum_von=DD.MM.YYYY")
    print("  GET /api/auftraege/<id>")
    print("  GET /api/schichten?va_id=<id>")
    print("  GET /api/zuordnungen?va_id=<id>")
    print("  GET /api/mitarbeiter")
    print("  GET /api/kunden")
    print("  GET /api/lookups")
    print("  GET /api/health")
    print("=" * 60)
    
    app.run(
        host='127.0.0.1',
        port=5001,
        debug=True,
        threaded=True
    )
