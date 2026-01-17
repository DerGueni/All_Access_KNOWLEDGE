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
# SERVER START
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    log("=" * 60)
    log("VBA Bridge Server startet auf Port 5002")
    log(f"win32com verfügbar: {HAS_WIN32COM}")
    log("=" * 60)

    # Server starten
    app.run(host='0.0.0.0', port=5002, debug=False, threaded=False)
