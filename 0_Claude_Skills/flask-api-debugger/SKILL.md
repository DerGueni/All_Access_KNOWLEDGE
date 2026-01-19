---
name: Flask API Debugger
description: Debuggt Python Flask API Server, findet Endpoint-Fehler, CORS-Probleme
when_to_use: API Server, Flask Fehler, 500 Error, CORS, fetch failed, Server startet nicht, Endpoint nicht gefunden
version: 1.0.0
---

# Flask API Debugger

## Häufige Flask Fehler

| Symptom | Ursache | Lösung |
|---------|---------|--------|
| 404 Not Found | Route fehlt | `@app.route()` prüfen |
| 500 Internal Server | Python-Fehler | Traceback in Konsole lesen |
| CORS Error | Header fehlen | `flask-cors` oder manuelle Header |
| Connection Refused | Server läuft nicht | `python api_server.py` starten |
| Method Not Allowed | Falsche HTTP-Methode | `methods=['GET', 'POST']` prüfen |
| JSON Decode Error | Falsches Format | `request.json` statt `request.form` |

## Debug-Modus aktivieren

```python
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## CORS richtig einrichten

### Option 1: flask-cors
```python
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
```

### Option 2: Manuelle Header
```python
@app.after_request
def after_request(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response
```

## Endpoint-Template

```python
@app.route('/api/endpoint_name', methods=['GET', 'POST', 'OPTIONS'])
def endpoint_name():
    # OPTIONS für CORS Preflight
    if request.method == 'OPTIONS':
        return '', 200
    
    if request.method == 'POST':
        try:
            data = request.json
            # Verarbeitung
            return jsonify({"status": "ok", "data": data})
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    
    # GET
    return jsonify({"message": "Hello"})
```

## Request-Debugging

```python
@app.route('/api/debug', methods=['POST'])
def debug_request():
    print("=== DEBUG ===")
    print(f"Method: {request.method}")
    print(f"Headers: {dict(request.headers)}")
    print(f"JSON: {request.json}")
    print(f"Form: {request.form}")
    print(f"Args: {request.args}")
    return jsonify({"received": True})
```

## Error Handler

```python
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": str(e)}), 500
```

## Alle Routen auflisten

```python
@app.route('/api/routes')
def list_routes():
    routes = []
    for rule in app.url_map.iter_rules():
        routes.append({
            "endpoint": rule.endpoint,
            "methods": list(rule.methods - {'HEAD', 'OPTIONS'}),
            "path": str(rule)
        })
    return jsonify(routes)
```

## Server-Status prüfen

```bash
# Windows PowerShell
curl http://localhost:5000/api/health

# Oder im Browser
# http://localhost:5000/api/routes
```

## Health-Check Endpoint

```python
@app.route('/api/health')
def health_check():
    return jsonify({
        "status": "ok",
        "server": "running",
        "timestamp": datetime.now().isoformat()
    })
```

## Logging einrichten

```python
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

@app.route('/api/test')
def test():
    logger.debug("Test endpoint called")
    logger.info("Processing request")
    return jsonify({"ok": True})
```

## Dateipfade
- API Server: `06_Server/api_server.py`
- Quick Server: `06_Server/quick_api_server.py`
