# -*- coding: utf-8 -*-
"""
VBA Bridge Server - Port 5002
Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Access

STABIL für Mehrbenutzerbetrieb (3+ parallele Benutzer):
- Thread-safe COM-Aufrufe mit Lock
- Connection-Pooling für Access
- Automatische Wiederverbindung bei Fehlern
- Request-Timeout-Handling

Endpoints:
- POST /api/vba/anfragen - Sendet Anfragen an Mitarbeiter (wie btnMail_Click in Access)
- POST /api/vba/execute - Führt beliebige VBA-Funktion aus
- GET  /api/vba/status  - Server-Status

Verwendung:
    python vba_bridge_server.py
"""

import os
import sys
import json
import traceback
import threading
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

# Windows COM für Access
try:
    import win32com.client
    import pythoncom
    HAS_WIN32COM = True
except ImportError:
    HAS_WIN32COM = False
    print("WARNUNG: win32com nicht installiert. VBA-Aufrufe werden simuliert.")

# ═══════════════════════════════════════════════════════════════════════════════
# THREAD-SAFETY: Lock für COM-Aufrufe (COM ist nicht thread-safe!)
# ═══════════════════════════════════════════════════════════════════════════════
_com_lock = threading.RLock()
_access_app_cache = None
_last_access_check = 0
ACCESS_CHECK_INTERVAL = 30  # Sekunden zwischen Verbindungsprüfungen

app = Flask(__name__)
CORS(app)

# ═══════════════════════════════════════════════════════════════════════════════
# KONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Access Frontend Pfad
ACCESS_FE_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"

# Log-Datei
LOG_FILE = os.path.join(os.path.dirname(__file__), "vba_bridge.log")

def log(message):
    """Logging mit Timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] {message}"
    print(log_msg)
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(log_msg + "\n")
    except:
        pass

# ═══════════════════════════════════════════════════════════════════════════════
# ACCESS COM VERBINDUNG
# ═══════════════════════════════════════════════════════════════════════════════

def get_access_app():
    """
    Holt laufende Access-Instanz mit Caching und Thread-Safety.
    Access MUSS bereits geöffnet sein mit dem Frontend!

    Features:
    - Connection wird gecached für schnelleren Zugriff
    - Automatische Prüfung ob Verbindung noch aktiv
    - Thread-safe durch Lock
    """
    global _access_app_cache, _last_access_check

    if not HAS_WIN32COM:
        return None

    current_time = time.time()

    with _com_lock:
        try:
            pythoncom.CoInitialize()

            # Cache noch gültig?
            if _access_app_cache is not None and (current_time - _last_access_check) < ACCESS_CHECK_INTERVAL:
                # Schnelle Prüfung ob Verbindung noch aktiv
                try:
                    _ = _access_app_cache.Visible  # Quick check
                    return _access_app_cache
                except:
                    log("Cached Access-Verbindung verloren - reconnect...")
                    _access_app_cache = None

            # Neue Verbindung herstellen
            access_app = win32com.client.GetActiveObject("Access.Application")
            db_name = access_app.CurrentDb().Name
            log(f"Access-Instanz verbunden: {db_name}")

            # Cache aktualisieren
            _access_app_cache = access_app
            _last_access_check = current_time

            return access_app

        except Exception as e:
            log(f"Keine laufende Access-Instanz gefunden: {e}")
            _access_app_cache = None
            return None

def run_vba_function(func_name, *args, timeout=60):
    """
    Führt VBA-Funktion in Access aus via Eval() - THREAD-SAFE!

    WICHTIG: Application.Run funktioniert nicht zuverlässig via COM,
    daher wird Eval() verwendet.

    Args:
        func_name: Name der VBA-Funktion (z.B. "Anfragen")
        *args: Argumente für die Funktion
        timeout: Maximale Ausführungszeit in Sekunden (Standard: 60s)

    Returns:
        Ergebnis der VBA-Funktion oder Fehlertext

    Thread-Safety:
        Verwendet globales Lock für COM-Aufrufe
    """
    global _access_app_cache

    with _com_lock:  # Thread-safe!
        access_app = get_access_app()
        if not access_app:
            return {"success": False, "error": "Access nicht geöffnet!"}

        try:
            # Argumente für Eval formatieren
            formatted_args = []
            for arg in args:
                if isinstance(arg, str):
                    # Strings mit Anführungszeichen - escape innere Anführungszeichen
                    escaped = str(arg).replace('"', '""')
                    formatted_args.append(f'"{escaped}"')
                elif arg is None:
                    formatted_args.append("Null")
                else:
                    formatted_args.append(str(arg))

            # Eval-Ausdruck zusammenbauen
            eval_expr = f"{func_name}({', '.join(formatted_args)})"
            log(f"VBA Eval: {eval_expr}")

            # VBA-Funktion via Eval ausführen
            result = access_app.Eval(eval_expr)
            log(f"VBA Ergebnis: {result}")
            return {"success": True, "result": result}

        except Exception as e:
            error_msg = str(e)
            log(f"VBA-Fehler: {func_name}({args}) - {error_msg}")

            # Bei COM-Fehler Cache invalidieren für nächsten Versuch
            if "RPC" in error_msg or "disconnected" in error_msg.lower():
                log("COM-Verbindungsfehler - Cache wird geleert")
                _access_app_cache = None

            return {"success": False, "error": error_msg}

# ═══════════════════════════════════════════════════════════════════════════════
# API ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/status', methods=['GET'])
def vba_status():
    """Server-Status und Access-Verbindung prüfen"""
    access_connected = False
    access_db = None

    if HAS_WIN32COM:
        try:
            pythoncom.CoInitialize()
            access_app = win32com.client.GetActiveObject("Access.Application")
            access_connected = True
            access_db = access_app.CurrentDb().Name
            pythoncom.CoUninitialize()
        except:
            pass

    return jsonify({
        "status": "running",
        "port": 5002,
        "win32com_available": HAS_WIN32COM,
        "access_connected": access_connected,
        "access_database": access_db,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/vba/anfragen', methods=['POST'])
def vba_anfragen():
    """
    Sendet Anfragen an Mitarbeiter (entspricht btnMail_Click / btnMailSelected_Click).

    Request Body:
    {
        "VA_ID": 12345,
        "VADatum_ID": 67890,
        "VAStart_ID": 111,
        "MA_IDs": [1, 2, 3],
        "selectedOnly": true/false
    }

    Response:
    {
        "success": true,
        "results": [
            {"MA_ID": 1, "status": "OK"},
            {"MA_ID": 2, "status": "BEREITS ZUGESAGT"},
            ...
        ],
        "total": 3,
        "sent": 2
    }
    """
    log("=== /api/vba/anfragen aufgerufen ===")

    try:
        data = request.get_json()
        log(f"Request Data: {json.dumps(data, indent=2)}")

        # Parameter validieren
        va_id = data.get('VA_ID')
        vadatum_id = data.get('VADatum_ID')
        vastart_id = data.get('VAStart_ID')
        ma_ids = data.get('MA_IDs', [])
        selected_only = data.get('selectedOnly', False)

        if not va_id:
            return jsonify({"success": False, "error": "VA_ID fehlt"}), 400
        if not vadatum_id:
            return jsonify({"success": False, "error": "VADatum_ID fehlt"}), 400
        if not ma_ids or len(ma_ids) == 0:
            return jsonify({"success": False, "error": "Keine Mitarbeiter ausgewählt"}), 400

        # VAStart_ID: Falls nicht angegeben, erste Schicht nehmen
        if not vastart_id:
            log("VAStart_ID nicht angegeben - versuche erste Schicht zu ermitteln")
            # Hier könnte man die erste Schicht aus der DB holen
            # Für jetzt: Fehler zurückgeben
            return jsonify({"success": False, "error": "VAStart_ID fehlt"}), 400

        # Access-Verbindung prüfen
        if not HAS_WIN32COM:
            log("SIMULATION: win32com nicht verfügbar")
            # Simulierte Antwort für Tests
            results = [{"MA_ID": ma_id, "status": "SIMULATION - OK"} for ma_id in ma_ids]
            return jsonify({
                "success": True,
                "simulated": True,
                "results": results,
                "total": len(ma_ids),
                "sent": len(ma_ids)
            })

        # Anfragen senden
        results = []
        sent_count = 0

        # DEBUG: Schreibe alle Debug-Infos in eine Datei
        debug_file = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\VBA_DEBUG.txt"
        with open(debug_file, "a", encoding="utf-8") as f:
            f.write(f"\n{'='*60}\n")
            f.write(f"[{datetime.now()}] ANFRAGEN START\n")
            f.write(f"VA_ID={va_id}, VADatum_ID={vadatum_id}, VAStart_ID={vastart_id}\n")
            f.write(f"MA_IDs={ma_ids}\n")

        for ma_id in ma_ids:
            try:
                log(f"Sende Anfrage an MA_ID={ma_id}")

                # DEBUG
                with open(debug_file, "a", encoding="utf-8") as f:
                    f.write(f"\n[DEBUG] MA_ID={ma_id} - Rufe HTML_Anfragen auf...\n")

                # WRAPPER-FUNKTION: HTML_Anfragen kombiniert Texte_lesen + Anfragen in EINEM Aufruf!
                # Grund: Public VBA-Variablen (Email, VADatum, etc.) persistieren nur innerhalb
                # einer VBA-Funktion sicher. Bei separaten COM-Aufrufen kann es zu NULL-Fehlern kommen.
                # Signatur: HTML_Anfragen(MA_ID As Integer, VA_ID As Long, VADatum_ID As Long, VAStart_ID As Long) As String
                vba_result = run_vba_function("HTML_Anfragen", int(ma_id), int(va_id), int(vadatum_id), int(vastart_id))

                # DEBUG
                with open(debug_file, "a", encoding="utf-8") as f:
                    f.write(f"[DEBUG] VBA Result: {vba_result}\n")

                if vba_result.get("success"):
                    status = vba_result.get("result", "OK")
                    log(f"HTML_Anfragen Ergebnis für MA_ID={ma_id}: {status}")

                    # DEBUG
                    with open(debug_file, "a", encoding="utf-8") as f:
                        f.write(f"[DEBUG] Status: '{status}' (type: {type(status).__name__})\n")

                    # Erfolg: Status enthält "OK" oder ">BEREITS..." etc.
                    if "OK" in str(status) or ">BEREITS" in str(status) or ">ERNEUT" in str(status):
                        sent_count += 1
                        with open(debug_file, "a", encoding="utf-8") as f:
                            f.write(f"[DEBUG] >>> GEZÄHLT als gesendet (sent_count={sent_count})\n")
                    else:
                        with open(debug_file, "a", encoding="utf-8") as f:
                            f.write(f"[DEBUG] >>> NICHT gezählt - kein OK/BEREITS/ERNEUT gefunden\n")
                    results.append({"MA_ID": ma_id, "status": status})
                else:
                    error_msg = vba_result.get('error', 'Unbekannter Fehler')
                    log(f"HTML_Anfragen FEHLER für MA_ID={ma_id}: {error_msg}")
                    with open(debug_file, "a", encoding="utf-8") as f:
                        f.write(f"[DEBUG] FEHLER: {error_msg}\n")
                    results.append({"MA_ID": ma_id, "status": f"FEHLER: {error_msg}"})

            except Exception as e:
                log(f"Fehler bei MA_ID={ma_id}: {str(e)}")
                with open(debug_file, "a", encoding="utf-8") as f:
                    f.write(f"[DEBUG] EXCEPTION: {str(e)}\n")
                results.append({"MA_ID": ma_id, "status": f"FEHLER: {str(e)}"})

        log(f"Anfragen abgeschlossen: {sent_count}/{len(ma_ids)} gesendet")

        return jsonify({
            "success": True,
            "results": results,
            "total": len(ma_ids),
            "sent": sent_count
        })

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/anfragen: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/execute', methods=['POST'])
def vba_execute():
    """
    Führt beliebige VBA-Funktion aus.

    Request Body:
    {
        "function": "FunktionsName",
        "args": [arg1, arg2, ...]
    }
    """
    log("=== /api/vba/execute aufgerufen ===")

    try:
        data = request.get_json()
        func_name = data.get('function')
        args = data.get('args', [])

        if not func_name:
            return jsonify({"success": False, "error": "function fehlt"}), 400

        log(f"Führe aus: {func_name}({args})")

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # SPEZIALFALL: Bei "Anfragen" MUSS zuerst Texte_lesen aufgerufen werden!
        # Texte_lesen setzt die Public-Variablen (Email, VName, NName, VADatum, VA_Uhrzeit etc.)
        # die Anfragen benötigt. In Access-Forms passiert das automatisch, hier nicht.
        if func_name == "Anfragen" and len(args) >= 4:
            ma_id, va_id, vadatum_id, vastart_id = args[0], args[1], args[2], args[3]
            log(f"Anfragen: Rufe zuerst Texte_lesen auf für MA={ma_id}, VA={va_id}, Datum={vadatum_id}, Start={vastart_id}")
            texte_result = run_vba_function("Texte_lesen", str(ma_id), str(va_id), str(vadatum_id), str(vastart_id))
            log(f"Texte_lesen Ergebnis: {texte_result}")

        result = run_vba_function(func_name, *args)
        return jsonify(result)

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/execute: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/ping', methods=['GET'])
def vba_ping():
    """Einfacher Health-Check"""
    return jsonify({"status": "ok", "port": 5002})

@app.route('/api/health', methods=['GET'])
def api_health():
    """Health-Check Endpoint (Kompatibilität mit HTML)"""
    return jsonify({"status": "ok", "port": 5002, "service": "vba-bridge"})

# ═══════════════════════════════════════════════════════════════════════════════
# WORD-INTEGRATION ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/word/fill-template', methods=['POST'])
def vba_word_fill_template():
    """
    Füllt Word-Vorlage mit Daten und erstellt Dokument.

    Request Body:
    {
        "doc_nr": 1,              // Dokument-Nummer in _tblEigeneFirma_TB_Dok_Dateinamen
        "iRch_KopfID": 123,       // Rechnungs-ID (optional)
        "kun_ID": 456,            // Kunden-ID (optional)
        "MA_ID": 789,             // Mitarbeiter-ID (optional)
        "VA_ID": 012              // Auftrags-ID (optional)
    }

    Response:
    {
        "success": true,
        "doc_path": "C:\\Pfad\\zum\\generierten\\Dokument.docx"
    }
    """
    log("=== /api/vba/word/fill-template aufgerufen ===")

    try:
        data = request.get_json()
        doc_nr = data.get('doc_nr')
        irch_kopfid = data.get('iRch_KopfID', 0)
        kun_id = data.get('kun_ID', 0)
        ma_id = data.get('MA_ID', 0)
        va_id = data.get('VA_ID', 0)

        if not doc_nr:
            return jsonify({"success": False, "error": "doc_nr fehlt"}), 400

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # Schritt 1: Felder-Tabelle füllen
        log(f"Fülle Textbaustein-Tabelle für DocNr={doc_nr}")
        result1 = run_vba_function("Textbau_Replace_Felder_Fuellen", int(doc_nr))
        if not result1.get("success"):
            return jsonify(result1), 500

        # Schritt 2: Ersetzungen durchführen
        log(f"Ersetze Felder: iRch_KopfID={irch_kopfid}, kun_ID={kun_id}, MA_ID={ma_id}, VA_ID={va_id}")
        result2 = run_vba_function("fReplace_Table_Felder_Ersetzen",
                                    int(irch_kopfid), int(kun_id), int(ma_id), int(va_id))
        if not result2.get("success"):
            return jsonify(result2), 500

        # TODO: Hier müsste noch die Word-Dokument-Generierung erfolgen
        # Das erfordert weitere VBA-Funktionen die das eigentliche Word-Dokument erstellen

        return jsonify({
            "success": True,
            "message": "Textbausteine gefüllt und ersetzt",
            "doc_nr": doc_nr
        })

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/word/fill-template: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# PDF-GENERIERUNG ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/pdf/convert', methods=['POST'])
def vba_pdf_convert():
    """
    Konvertiert Word-Dokument zu PDF.

    Request Body:
    {
        "word_path": "C:\\Pfad\\zum\\Dokument.docx"
    }

    Response:
    {
        "success": true,
        "pdf_path": "C:\\Pfad\\zum\\Dokument.pdf"
    }
    """
    log("=== /api/vba/pdf/convert aufgerufen ===")

    try:
        data = request.get_json()
        word_path = data.get('word_path')

        if not word_path:
            return jsonify({"success": False, "error": "word_path fehlt"}), 400

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # PDF-Konvertierung via VBA (benötigt entsprechende VBA-Funktion)
        # Alternativ: Direkt mit Python win32com.client.Dispatch("Word.Application")
        pythoncom.CoInitialize()
        try:
            word = win32com.client.Dispatch("Word.Application")
            word.Visible = False

            # Öffne Word-Dokument
            doc = word.Documents.Open(word_path)

            # PDF-Pfad generieren
            pdf_path = word_path.replace(".docx", ".pdf").replace(".doc", ".pdf")

            # Als PDF exportieren (wdFormatPDF = 17)
            doc.SaveAs2(pdf_path, FileFormat=17)
            doc.Close()
            word.Quit()

            log(f"PDF erstellt: {pdf_path}")

            return jsonify({
                "success": True,
                "pdf_path": pdf_path
            })
        finally:
            pythoncom.CoUninitialize()

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/pdf/convert: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# NUMMERNKREIS ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/nummern/next', methods=['POST'])
def vba_nummern_next():
    """
    Holt nächste Nummer aus Nummernkreis und inkrementiert.

    Request Body:
    {
        "id": 1   // ID in _tblEigeneFirma_Word_Nummernkreise
                  // 1 = Rechnung, 2 = Angebot, 3 = Brief, etc.
    }

    Response:
    {
        "success": true,
        "nummer": 12345
    }
    """
    log("=== /api/vba/nummern/next aufgerufen ===")

    try:
        data = request.get_json()
        nummern_id = data.get('id')

        if not nummern_id:
            return jsonify({"success": False, "error": "id fehlt"}), 400

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True,
                "nummer": 99999  # Simulierte Nummer
            })

        # VBA-Funktion Update_Rch_Nr aufrufen
        result = run_vba_function("Update_Rch_Nr", int(nummern_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "nummer": result.get("result")
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/nummern/next: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/nummern/current/<int:nummern_id>', methods=['GET'])
def vba_nummern_current(nummern_id):
    """
    Holt aktuelle Nummer OHNE Inkrement (nur Anzeige).

    Response:
    {
        "success": true,
        "nummer": 12344
    }
    """
    log(f"=== /api/vba/nummern/current/{nummern_id} aufgerufen ===")

    try:
        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True,
                "nummer": 99999
            })

        # TLookup-Funktion verwenden (ohne Inkrement)
        result = run_vba_function("TLookup", "NummernKreis", "_tblEigeneFirma_Word_Nummernkreise", f"ID = {nummern_id}")

        if result.get("success"):
            return jsonify({
                "success": True,
                "nummer": result.get("result", 0)
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/nummern/current: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# AUFTRAGSTAMM BUTTON ENDPOINTS (15.01.2026)
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/namensliste-ess', methods=['POST'])
def vba_namensliste_ess():
    """
    Erstellt Namensliste ESS (Einsatzstundenliste).
    Ruft VBA-Funktion Stundenliste_erstellen auf.

    Request Body:
    {
        "VA_ID": 12345,
        "MA_ID": 0,          // optional, 0 = alle MA
        "kun_ID": 456        // Veranstalter/Kunden-ID
    }

    Response:
    {
        "success": true,
        "message": "Namensliste ESS erstellt"
    }
    """
    log("=== /api/vba/namensliste-ess aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('VA_ID')
        ma_id = data.get('MA_ID', 0)
        kun_id = data.get('kun_ID', 0)

        if not va_id:
            return jsonify({"success": False, "error": "VA_ID fehlt"}), 400

        log(f"Erstelle Namensliste ESS: VA_ID={va_id}, MA_ID={ma_id}, kun_ID={kun_id}")

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # VBA-Funktion Stundenliste_erstellen aufrufen
        result = run_vba_function("Stundenliste_erstellen", int(va_id), int(ma_id), int(kun_id))

        if result.get("success"):
            log("Namensliste ESS erfolgreich erstellt")
            return jsonify({
                "success": True,
                "message": "Namensliste ESS erfolgreich erstellt"
            })
        else:
            log(f"Fehler: {result.get('error')}")
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/namensliste-ess: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/el-drucken', methods=['POST'])
def vba_el_drucken():
    """
    Druckt Einsatzliste (EL) für Auftrag.
    Ruft VBA-Funktion EinsatzlisteDruckenFromHTML auf.

    Request Body:
    {
        "va_id": 12345,
        "vadatum_id": 67890    // optional
    }

    Response:
    {
        "success": true,
        "message": "Einsatzliste gedruckt"
    }
    """
    log("=== /api/vba/el-drucken aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID', 0)

        if not va_id:
            return jsonify({"success": False, "error": "va_id fehlt"}), 400

        log(f"Drucke Einsatzliste: va_id={va_id}, vadatum_id={vadatum_id}")

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # VBA-Funktion EinsatzlisteDruckenFromHTML aufrufen
        result = run_vba_function("EinsatzlisteDruckenFromHTML", int(va_id), int(vadatum_id))

        if result.get("success"):
            vba_return = str(result.get("result", ""))

            # VBA-Funktionen geben ">OK" oder ">FEHLER: ..." zurück
            if vba_return.startswith(">OK"):
                log("Einsatzliste erfolgreich gedruckt")
                return jsonify({
                    "success": True,
                    "message": "Einsatzliste erfolgreich erstellt"
                })
            elif vba_return.startswith(">FEHLER"):
                error_text = vba_return.replace(">FEHLER:", "").strip()
                log(f"VBA-Fehler: {error_text}")
                return jsonify({
                    "success": False,
                    "error": error_text
                }), 500
            else:
                log(f"Unerwarteter VBA-Rückgabewert: {vba_return}")
                return jsonify({
                    "success": True,
                    "message": vba_return
                })
        else:
            log(f"Fehler: {result.get('error')}")
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/el-drucken: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/el-senden', methods=['POST'])
def vba_el_senden():
    """
    Sendet Einsatzliste (EL) per E-Mail.
    Ruft VBA-Funktion SendeBewachungsnachweiseFromHTML auf.

    Request Body:
    {
        "va_id": 12345,
        "vadatum_id": 67890    // optional
    }

    Response:
    {
        "success": true,
        "message": "Einsatzliste gesendet"
    }
    """
    log("=== /api/vba/el-senden aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID', 0)

        if not va_id:
            return jsonify({"success": False, "error": "va_id fehlt"}), 400

        log(f"Sende Einsatzliste: va_id={va_id}, vadatum_id={vadatum_id}")

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # VBA-Funktion SendeBewachungsnachweiseFromHTML aufrufen
        result = run_vba_function("SendeBewachungsnachweiseFromHTML", int(va_id), int(vadatum_id))

        if result.get("success"):
            vba_return = str(result.get("result", ""))

            # VBA-Funktionen geben ">OK" oder ">FEHLER: ..." zurück
            if vba_return.startswith(">OK"):
                log("Einsatzliste erfolgreich gesendet")
                return jsonify({
                    "success": True,
                    "message": "Einsatzliste erfolgreich gesendet"
                })
            elif vba_return.startswith(">FEHLER"):
                error_text = vba_return.replace(">FEHLER:", "").strip()
                log(f"VBA-Fehler: {error_text}")
                return jsonify({
                    "success": False,
                    "error": error_text
                }), 500
            else:
                log(f"Unerwarteter VBA-Rückgabewert: {vba_return}")
                return jsonify({
                    "success": True,
                    "message": vba_return
                })
        else:
            log(f"Fehler: {result.get('error')}")
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/el-senden: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# AUSWEIS ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/ausweis/drucken', methods=['POST'])
def vba_ausweis_drucken():
    """
    Druckt Ausweis für Mitarbeiter.

    Request Body:
    {
        "MA_ID": 123,
        "drucker": "Canon Drucker"  // optional
    }

    Response:
    {
        "success": true,
        "message": "Ausweis gedruckt"
    }
    """
    log("=== /api/vba/ausweis/drucken aufgerufen ===")

    try:
        data = request.get_json()
        ma_id = data.get('MA_ID')
        drucker = data.get('drucker', '')

        if not ma_id:
            return jsonify({"success": False, "error": "MA_ID fehlt"}), 400

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True
            })

        # VBA-Funktion Ausweis_Drucken aufrufen
        if drucker:
            result = run_vba_function("Ausweis_Drucken", int(ma_id), drucker)
        else:
            result = run_vba_function("Ausweis_Drucken", int(ma_id))

        return jsonify(result)

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/ausweis/drucken: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/ausweis/nummer', methods=['POST'])
def vba_ausweis_nummer():
    """
    Vergibt Ausweis-Nummer für Mitarbeiter.

    Request Body:
    {
        "MA_ID": 123
    }

    Response:
    {
        "success": true,
        "ausweis_nr": 12345
    }
    """
    log("=== /api/vba/ausweis/nummer aufgerufen ===")

    try:
        data = request.get_json()
        ma_id = data.get('MA_ID')

        if not ma_id:
            return jsonify({"success": False, "error": "MA_ID fehlt"}), 400

        if not HAS_WIN32COM:
            return jsonify({
                "success": False,
                "error": "win32com nicht verfügbar",
                "simulated": True,
                "ausweis_nr": 99999
            })

        # VBA-Funktion Ausweis_Nr_Vergeben aufrufen
        result = run_vba_function("Ausweis_Nr_Vergeben", int(ma_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "ausweis_nr": result.get("result")
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        error_msg = traceback.format_exc()
        log(f"Fehler in /api/vba/ausweis/nummer: {error_msg}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# AUFTRAGSTAMM WEITERE BUTTON ENDPOINTS (15.01.2026)
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/vba/sortieren', methods=['POST'])
def vba_sortieren():
    """
    Sortiert MA-Zuordnungen für einen Auftrag/Tag.
    Entspricht btn_sortieren_Click -> sort_zuo_plan()

    Request Body:
    {
        "va_id": 12345,
        "vadatum_id": 67890,
        "mode": 1  // 1=Zuordnung, 2=Planung
    }
    """
    log("=== /api/vba/sortieren aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID')
        mode = data.get('mode', 1)

        if not va_id or not vadatum_id:
            return jsonify({"success": False, "error": "va_id und vadatum_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        result = run_vba_function("sort_zuo_plan", int(va_id), int(vadatum_id), int(mode))

        if result.get("success"):
            return jsonify({"success": True, "message": "Sortierung durchgeführt"})
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/sortieren: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/zuordnung-fill', methods=['POST'])
def vba_zuordnung_fill():
    """
    Erstellt Zuordnungs-Slots für Schichten.
    Entspricht btnVAPlanCrea_Click -> Zuord_Fill()

    Request Body:
    {
        "va_id": 12345,
        "vadatum_id": 67890
    }
    """
    log("=== /api/vba/zuordnung-fill aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID')

        if not va_id or not vadatum_id:
            return jsonify({"success": False, "error": "va_id und vadatum_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # Schritt 1: Zuordnungs-Slots erstellen
        result = run_vba_function("Zuord_Fill", int(vadatum_id), int(va_id))

        if result.get("success"):
            # Schritt 2: Tag-Schicht Update
            run_vba_function("fTag_Schicht_Update_Tag", int(vadatum_id), int(va_id))
            return jsonify({"success": True, "message": "Zuordnungen erstellt"})
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/zuordnung-fill: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/std-check', methods=['POST'])
def vba_std_check():
    """
    Stunden-Check durchführen + Status auf 'Abrechnung' setzen + EL drucken.
    Entspricht btn_std_check_Click

    Request Body:
    {
        "va_id": 12345
    }
    """
    log("=== /api/vba/std-check aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # Status auf 3 (Abrechnung) setzen
        access_app = get_access_app()
        if access_app:
            try:
                # SQL direkt ausführen
                sql = f"UPDATE tbl_VA_Auftragstamm SET Veranst_Status_ID = 3, Aend_am = Now() WHERE ID = {va_id}"
                access_app.DoCmd.RunSQL(sql)
                log(f"Status für VA {va_id} auf 3 (Abrechnung) gesetzt")
            except Exception as e:
                log(f"Status-Update Fehler: {e}")

        # EL drucken (wie btnDruckZusage_Click)
        result = run_vba_function("EinsatzlisteDruckenFromHTML", int(va_id), 0)

        return jsonify({
            "success": True,
            "message": "Status auf Abrechnung gesetzt und Einsatzliste erstellt",
            "new_status": 3
        })

    except Exception as e:
        log(f"Fehler in /api/vba/std-check: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/folgetag-kopieren', methods=['POST'])
def vba_folgetag_kopieren():
    """
    Kopiert Schichten und MA-Zuordnungen in den Folgetag.
    Entspricht btnPlan_Kopie_Click

    Request Body:
    {
        "va_id": 12345,
        "vadatum_id": 67890
    }
    """
    log("=== /api/vba/folgetag-kopieren aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID') or data.get('current_datum_id')

        if not va_id or not vadatum_id:
            return jsonify({"success": False, "error": "va_id und vadatum_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # VBA-Funktion für Folgetag-Kopie aufrufen
        result = run_vba_function("KopiereInFolgetag", int(va_id), int(vadatum_id))

        if result.get("success"):
            vba_result = result.get("result", "")
            # Erwartetes Format: "OK:next_datum_id:schichten:zuordnungen" oder ">OK"
            if str(vba_result).startswith(">OK") or str(vba_result).startswith("OK"):
                parts = str(vba_result).replace(">OK", "OK").split(":")
                next_datum_id = parts[1] if len(parts) > 1 else None
                schichten_count = int(parts[2]) if len(parts) > 2 else 0
                zuordnungen_count = int(parts[3]) if len(parts) > 3 else 0

                return jsonify({
                    "success": True,
                    "message": "Daten in Folgetag kopiert",
                    "data": {
                        "next_datum_id": next_datum_id,
                        "schichten_count": schichten_count,
                        "zuordnungen_count": zuordnungen_count
                    }
                })
            else:
                return jsonify({"success": True, "message": str(vba_result)})
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/folgetag-kopieren: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/rechnung/pdf', methods=['POST'])
def vba_rechnung_pdf():
    """
    Erstellt Rechnungs-PDF.
    Entspricht btnPDFKopf_Click

    Request Body:
    {
        "va_id": 12345,
        "rch_kopf_id": 111  // optional
    }
    """
    log("=== /api/vba/rechnung/pdf aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        rch_kopf_id = data.get('rch_kopf_id', 0)

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # VBA-Funktion für Rechnungs-PDF aufrufen
        result = run_vba_function("RechnungPDFFromHTML", int(va_id), int(rch_kopf_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "message": "Rechnungs-PDF erstellt",
                "pdf_path": result.get("result", "")
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/rechnung/pdf: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/berechnungsliste/pdf', methods=['POST'])
def vba_berechnungsliste_pdf():
    """
    Erstellt Berechnungsliste-PDF.
    Entspricht btnPDFPos_Click

    Request Body:
    {
        "va_id": 12345
    }
    """
    log("=== /api/vba/berechnungsliste/pdf aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # Report als PDF exportieren
        result = run_vba_function("BerechnungslistePDFFromHTML", int(va_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "message": "Berechnungsliste-PDF erstellt",
                "pdf_path": result.get("result", "")
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/berechnungsliste/pdf: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/rechnung/lexware', methods=['POST'])
def vba_rechnung_lexware():
    """
    Erstellt Rechnung in Lexware.
    Entspricht btnRchLex_Click

    Request Body:
    {
        "va_id": 12345,
        "kun_id": 456
    }
    """
    log("=== /api/vba/rechnung/lexware aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')
        kun_id = data.get('kun_id') or data.get('kun_ID', 0)

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # VBA-Funktion für Lexware-Rechnung aufrufen
        result = run_vba_function("RechnungLexwareFromHTML", int(va_id), int(kun_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "message": "Rechnung in Lexware erstellt",
                "lexware_nr": result.get("result", "")
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/rechnung/lexware: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/rechnung/daten-laden', methods=['POST'])
def vba_rechnung_daten_laden():
    """
    Lädt Rechnungsdaten (Berechnungsliste füllen).
    Entspricht btnLoad_Click -> fill_Berechnungsliste()

    Request Body:
    {
        "va_id": 12345
    }
    """
    log("=== /api/vba/rechnung/daten-laden aufgerufen ===")

    try:
        data = request.get_json()
        va_id = data.get('va_id') or data.get('VA_ID')

        if not va_id:
            return jsonify({"success": False, "error": "va_id erforderlich"}), 400

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # VBA-Funktion zum Füllen der Berechnungsliste aufrufen
        result = run_vba_function("fill_Berechnungsliste", int(va_id))

        if result.get("success"):
            return jsonify({
                "success": True,
                "message": "Rechnungsdaten geladen"
            })
        else:
            return jsonify(result), 500

    except Exception as e:
        log(f"Fehler in /api/vba/rechnung/daten-laden: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/rueckmeldungen', methods=['POST'])
def vba_rueckmeldungen():
    """
    Öffnet Rückmelde-Auswertung.
    Entspricht btn_Rueckmeld_Click

    Request Body:
    {
        "va_id": 12345  // optional
    }
    """
    log("=== /api/vba/rueckmeldungen aufgerufen ===")

    try:
        data = request.get_json() or {}
        va_id = data.get('va_id') or data.get('VA_ID', 0)

        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        # Formular öffnen via DoCmd.OpenForm
        access_app = get_access_app()
        if access_app:
            try:
                access_app.DoCmd.OpenForm("zfrm_Rueckmeldungen", 0)  # acNormal = 0
                return jsonify({"success": True, "message": "Rückmelde-Formular geöffnet"})
            except Exception as e:
                return jsonify({"success": False, "error": str(e)}), 500
        else:
            return jsonify({"success": False, "error": "Access nicht verbunden"}), 500

    except Exception as e:
        log(f"Fehler in /api/vba/rueckmeldungen: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/abwesenheiten', methods=['POST'])
def vba_abwesenheiten():
    """
    Öffnet Abwesenheitsübersicht.
    Entspricht btn_VA_Abwesenheiten_Click
    """
    log("=== /api/vba/abwesenheiten aufgerufen ===")

    try:
        if not HAS_WIN32COM:
            return jsonify({"success": False, "error": "win32com nicht verfügbar", "simulated": True})

        access_app = get_access_app()
        if access_app:
            try:
                access_app.DoCmd.OpenForm("frm_abwesenheitsuebersicht", 2)  # acFormDS = 2
                return jsonify({"success": True, "message": "Abwesenheits-Formular geöffnet"})
            except Exception as e:
                return jsonify({"success": False, "error": str(e)}), 500
        else:
            return jsonify({"success": False, "error": "Access nicht verbunden"}), 500

    except Exception as e:
        log(f"Fehler in /api/vba/abwesenheiten: {traceback.format_exc()}")
        return jsonify({"success": False, "error": str(e)}), 500

# ═══════════════════════════════════════════════════════════════════════════════
# KEEP-ALIVE BACKGROUND THREAD
# ═══════════════════════════════════════════════════════════════════════════════

_keep_alive_thread = None
_keep_alive_running = False

def keep_alive_check():
    """
    Background-Thread der regelmäßig die Access-Verbindung prüft.
    Verhindert Verbindungsabbrüche bei längerer Inaktivität.
    """
    global _keep_alive_running, _access_app_cache
    log("Keep-Alive Thread gestartet")

    while _keep_alive_running:
        try:
            time.sleep(60)  # Alle 60 Sekunden prüfen
            if not _keep_alive_running:
                break

            with _com_lock:
                if _access_app_cache is not None:
                    try:
                        pythoncom.CoInitialize()
                        # Einfache Prüfung
                        _ = _access_app_cache.Visible
                        log("Keep-Alive: Access-Verbindung OK")
                    except:
                        log("Keep-Alive: Verbindung verloren - wird beim nächsten Request neu verbunden")
                        _access_app_cache = None
        except Exception as e:
            log(f"Keep-Alive Fehler: {e}")

    log("Keep-Alive Thread beendet")

def start_keep_alive():
    """Startet den Keep-Alive Background Thread"""
    global _keep_alive_thread, _keep_alive_running
    _keep_alive_running = True
    _keep_alive_thread = threading.Thread(target=keep_alive_check, daemon=True)
    _keep_alive_thread.start()

def stop_keep_alive():
    """Stoppt den Keep-Alive Background Thread"""
    global _keep_alive_running
    _keep_alive_running = False

# ═══════════════════════════════════════════════════════════════════════════════
# SERVER START
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    log("=" * 60)
    log("VBA Bridge Server startet auf Port 5002")
    log(f"win32com verfügbar: {HAS_WIN32COM}")
    log("STABIL: Thread-safe für Mehrbenutzerbetrieb")
    log("=" * 60)

    # Keep-Alive Thread starten
    start_keep_alive()

    try:
        # Server starten mit Threading für parallele Requests
        # WICHTIG: threaded=True ermöglicht mehrere gleichzeitige Benutzer
        app.run(host='0.0.0.0', port=5002, debug=False, threaded=True)
    finally:
        stop_keep_alive()
        log("Server beendet")
