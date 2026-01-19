---
name: CONSYS API Endpoint Creator
description: Erstellt neue API-Endpoints für HTML-Formulare
when_to_use: Neuer Endpoint benötigt, Daten von Access nach HTML
version: 1.0.0
---

# API Endpoint Creator

## Schnelltemplate

```python
@app.route('/api/ENDPOINT_NAME', methods=['GET', 'POST'])
def endpoint_name():
    if request.method == 'POST':
        data = request.json
        # Verarbeitung
        return jsonify({"status": "ok"})
    else:
        # GET: Daten zurückgeben
        return jsonify({"data": []})
```

## Regeln (aus HTML_RULES.txt)
- Bestehende Endpoints NICHT ändern
- Neue Endpoints am Ende der Datei
- CORS-Header immer setzen
- Dummy-Daten für Tests erlaubt

## Dateipfad
`06_Server/api_server.py`

## JS-Aufruf (Frontend)
```javascript
fetch('/api/ENDPOINT_NAME', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(data)
})
.then(r => r.json())
.then(console.log);
```
