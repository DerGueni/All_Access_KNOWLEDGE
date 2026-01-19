---
name: CONSYS Button Fixer
description: Repariert Buttons die in Access funktionieren aber in HTML nicht
when_to_use: Button reagiert nicht, onclick fehlt, API-Call schlägt fehl
version: 1.0.0
---

# CONSYS Button Fixer

## Diagnose-Checkliste

| Check | Befehl |
|-------|--------|
| Button hat onclick? | Grep nach `id="btnName"` + `onclick` |
| API-Endpoint existiert? | Check `06_Server/api_server.py` |
| Funktion in JS? | Check `04_HTML_Forms/forms3/js/` |

## Typische Fehler

### 1. onclick fehlt
```html
<!-- FALSCH -->
<button id="btnSave">Speichern</button>

<!-- RICHTIG -->
<button id="btnSave" onclick="saveData()">Speichern</button>
```

### 2. API-Endpoint fehlt
```python
# In api_server.py hinzufügen:
@app.route('/api/save', methods=['POST'])
def save_data():
    return jsonify({"status": "ok"})
```

### 3. CORS-Fehler
```python
# Header prüfen
response.headers['Access-Control-Allow-Origin'] = '*'
```

## Reparatur-Workflow

1. VBA-Code lesen → Welche Aktion?
2. HTML-Button finden → onclick vorhanden?
3. JS-Funktion prüfen → API-Call korrekt?
4. API-Endpoint prüfen → Route existiert?
5. Testen → Browser DevTools F12

## Dateipfade
- HTML: `04_HTML_Forms/forms3/*.html`
- JS: `04_HTML_Forms/forms3/js/`
- API: `06_Server/api_server.py`
- VBA: `01_VBA/`
