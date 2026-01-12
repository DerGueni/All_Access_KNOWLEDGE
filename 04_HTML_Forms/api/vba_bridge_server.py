# -*- coding: utf-8 -*-
"""
VBA Bridge Server - Port 5002
Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Access

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
    Holt laufende Access-Instanz oder startet neue.
    Access MUSS bereits geöffnet sein mit dem Frontend!
    """
    if not HAS_WIN32COM:
        return None

    pythoncom.CoInitialize()

    try:
        # Versuche bestehende Access-Instanz zu finden
        access_app = win32com.client.GetActiveObject("Access.Application")
        log(f"Bestehende Access-Instanz gefunden: {access_app.CurrentDb().Name}")
        return access_app
    except:
        log("Keine laufende Access-Instanz gefunden!")
        return None

def run_vba_function(func_name, *args):
    """
    Führt VBA-Funktion in Access aus via Eval().

    WICHTIG: Application.Run funktioniert nicht zuverlässig via COM,
    daher wird Eval() verwendet.

    Args:
        func_name: Name der VBA-Funktion (z.B. "Anfragen")
        *args: Argumente für die Funktion

    Returns:
        Ergebnis der VBA-Funktion oder Fehlertext
    """
    access_app = get_access_app()
    if not access_app:
        return {"success": False, "error": "Access nicht geöffnet!"}

    try:
        # Argumente für Eval formatieren
        formatted_args = []
        for arg in args:
            if isinstance(arg, str):
                # Strings mit Anführungszeichen
                formatted_args.append(f'"{arg}"')
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
        return {"success": False, "error": error_msg}
    finally:
        pythoncom.CoUninitialize()

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

        for ma_id in ma_ids:
            try:
                log(f"Sende Anfrage an MA_ID={ma_id}")

                # VBA-Funktion "Anfragen" aufrufen
                # Signatur: Anfragen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
                vba_result = run_vba_function("Anfragen", int(ma_id), int(va_id), int(vadatum_id), int(vastart_id))

                if vba_result.get("success"):
                    status = vba_result.get("result", "OK")
                    if "OK" in str(status):
                        sent_count += 1
                    results.append({"MA_ID": ma_id, "status": status})
                else:
                    results.append({"MA_ID": ma_id, "status": f"FEHLER: {vba_result.get('error')}"})

            except Exception as e:
                log(f"Fehler bei MA_ID={ma_id}: {str(e)}")
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
# SERVER START
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    log("=" * 60)
    log("VBA Bridge Server startet auf Port 5002")
    log(f"win32com verfügbar: {HAS_WIN32COM}")
    log("=" * 60)

    # Server starten
    app.run(host='0.0.0.0', port=5002, debug=False, threaded=False)
