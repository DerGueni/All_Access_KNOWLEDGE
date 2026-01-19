---
name: API Tester
description: Testet REST API Endpoints, validiert Responses, prüft Erreichbarkeit
when_to_use: API testen, Endpoint prüfen, Response validieren, Server erreichbar, curl Test
version: 1.0.0
---

# API Tester

## Schnell-Tests

### PowerShell/CMD
```powershell
# GET Request
curl http://localhost:5000/api/health

# POST Request
curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"Test\"}" http://localhost:5000/api/data

# Alle Routen auflisten
curl http://localhost:5000/api/routes
```

### Browser Console (F12)
```javascript
// GET
fetch('http://localhost:5000/api/health')
    .then(r => r.json())
    .then(console.log);

// POST
fetch('http://localhost:5000/api/data', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({name: 'Test'})
})
.then(r => r.json())
.then(console.log);
```

## Response-Codes prüfen

| Code | Bedeutung | Aktion |
|------|-----------|--------|
| 200 | OK | ✓ Alles gut |
| 201 | Created | ✓ Ressource erstellt |
| 400 | Bad Request | Request-Body prüfen |
| 404 | Not Found | URL/Route prüfen |
| 405 | Method Not Allowed | GET/POST richtig? |
| 500 | Server Error | Server-Logs prüfen |

## Test-Checkliste

### Vor dem Test
- [ ] Server läuft (`python api_server.py`)
- [ ] Richtiger Port (default: 5000)
- [ ] CORS aktiviert

### Während Test
- [ ] Status-Code prüfen
- [ ] Response-Body prüfen
- [ ] Content-Type: application/json
- [ ] Keine CORS-Fehler

### Nach Test
- [ ] Erwartete Daten erhalten
- [ ] Format korrekt
- [ ] Keine Fehler in Server-Console

## Endpoint-Dokumentation Template

```markdown
## GET /api/mitarbeiter

Gibt Liste aller Mitarbeiter zurück.

**Request:**
- Method: GET
- URL: http://localhost:5000/api/mitarbeiter

**Response (200 OK):**
```json
{
    "status": "ok",
    "data": [
        {"id": 1, "name": "Max Mustermann"},
        {"id": 2, "name": "Erika Musterfrau"}
    ]
}
```

**Fehler:**
- 404: Keine Mitarbeiter gefunden
- 500: Datenbankfehler
```

## Python Test-Script

```python
import requests

BASE_URL = 'http://localhost:5000'

def test_health():
    r = requests.get(f'{BASE_URL}/api/health')
    assert r.status_code == 200
    print('✓ Health Check OK')

def test_get_data():
    r = requests.get(f'{BASE_URL}/api/data')
    assert r.status_code == 200
    assert 'data' in r.json()
    print('✓ GET Data OK')

def test_post_data():
    r = requests.post(
        f'{BASE_URL}/api/data',
        json={'name': 'Test'},
        headers={'Content-Type': 'application/json'}
    )
    assert r.status_code in [200, 201]
    print('✓ POST Data OK')

if __name__ == '__main__':
    test_health()
    test_get_data()
    test_post_data()
    print('\n✓✓✓ Alle Tests bestanden!')
```

## Batch-Test (Windows)

```batch
@echo off
echo Testing API Endpoints...
echo.

echo [1] Health Check
curl -s http://localhost:5000/api/health
echo.

echo [2] Get Routes
curl -s http://localhost:5000/api/routes
echo.

echo [3] Test POST
curl -s -X POST -H "Content-Type: application/json" -d "{\"test\":true}" http://localhost:5000/api/test
echo.

echo Done!
pause
```

## Dateipfade
- API Server: `06_Server/api_server.py`
- Test-Scripts: `06_Server/tests/`
