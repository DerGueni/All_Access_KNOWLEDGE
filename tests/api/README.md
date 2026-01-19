# API Tests

## Abwesenheiten CRUD
- Skript: [test_abwesenheiten_api.py](test_abwesenheiten_api.py)
- Zweck: Fuehrt End-to-End-CRUD gegen `/api/abwesenheiten` aus und prueft, dass die neuen Datensaetze auch ueber das Filter-Listing erreichbar sind.

### Voraussetzungen
1. Flask-API laeuft lokal (Standard `http://localhost:5000`).
2. Paket `requests` ist installiert (`pip install requests`).
3. Mindestens ein aktiver Mitarbeiter existiert, ansonsten schlägt der Test fehl.

### Ausfuehrung
```bash
# Optional Basis-URL anpassen
$env:CONSYS_API_URL = "http://localhost:5000/api"

# Test starten
python tests/api/test_abwesenheiten_api.py
```
Eine erfolgreiche Ausfuehrung gibt `Abwesenheiten-API CRUD-Test erfolgreich abgeschlossen.` aus.
